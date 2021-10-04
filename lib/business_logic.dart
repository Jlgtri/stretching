import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:darq/darq.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stretching/api_smstretching.dart';
import 'package:stretching/api_yclients.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/main.dart';
import 'package:stretching/models/smstretching/sm_abonement_model.dart';
import 'package:stretching/models/smstretching/sm_record_model.dart';
import 'package:stretching/models/smstretching/sm_studio_options_model.dart';
import 'package:stretching/models/yclients/activity_model.dart';
import 'package:stretching/models/yclients/good_model.dart';
import 'package:stretching/models/yclients/good_transaction_model.dart';
import 'package:stretching/models/yclients/record_model.dart';
import 'package:stretching/models/yclients/storage_operation_model.dart';
import 'package:stretching/models/yclients/transaction_model.dart';
import 'package:stretching/models/yclients/user_model.dart';
import 'package:stretching/providers/combined_providers.dart';
import 'package:stretching/providers/firebase_providers.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/utils/enum_to_string.dart';
import 'package:stretching/utils/logger.dart';
import 'package:stretching/widgets/book_screens.dart';
import 'package:stretching/widgets/error_screen.dart';
import 'package:stretching/widgets/navigation/modals/payment_picker.dart';
import 'package:tinkoff_acquiring/tinkoff_acquiring.dart' hide Route;

/// The result of [BusinessLogic.book].
enum BookResult {
  /// Means activity was booked by deposit with regular price.
  depositRegular,

  /// Means activity was booked by deposit with discount.
  depositDiscount,

  /// Means activity was booked with abonement.
  abonement,

  /// Means activity was booked with abonement that was just have been bought.
  newAbonement,

  /// Means activity was booked with a regular payment.
  regular,

  /// Means activity was booked with a payment with discount.
  discount
}

/// The exception type of the [CancelBookException].
enum CancelBookExceptionType {
  /// Means the record was already canceled or not found.
  notFound,

  /// Means the record was tried to be removed too late before it's date.
  timeHacking
}

/// The exception types for [BookException].
enum BookExceptionType {
  /// Means a general exception.
  general,

  /// Means user has already applied for activity.
  alreadyApplied,

  /// Means user tried to apply for invalid activity.
  invalidActivity,

  /// Means activity is full.
  full,

  /// Means an exception during payment.
  payment,

  /// Means user dismissed the booking.
  dismiss,

  /// Means user have waited for too long while booking.
  timeout
}

/// The extra data provided for the [BookExceptionType].
extension BookExceptionTypeData on BookExceptionType {
  /// The title of this book exception to show to user if any.
  ///
  /// If no title exists, returns the title for the [BookExceptionType.general].
  String get title {
    final key = '${TR.failedBook}.${enumToString(this)}.title';
    final value = key.tr();
    return this != BookExceptionType.general && key == value
        ? BookExceptionType.general.title
        : value;
  }

  /// The information of this book exception to show to user if any.
  ///
  /// If no information exists, returns the information for the
  /// [BookExceptionType.general].
  String get info {
    final key = '${TR.failedBook}.${enumToString(this)}.info';
    final value = key.tr();
    return this != BookExceptionType.general && key == value
        ? BookExceptionType.general.info
        : value;
  }

  /// The information of this book exception to show to user if any.
  ///
  /// If no information exists, returns the information for the
  /// [BookExceptionType.general].
  String get button {
    final key = '${TR.failedBook}.${enumToString(this)}.button';
    final value = key.tr();
    return this != BookExceptionType.general && key == value
        ? BookExceptionType.general.button
        : value;
  }
}

/// The exception on [BusinessLogic].
class CancelBookException implements Exception {
  /// The exception on [BusinessLogic].
  const CancelBookException(final this.type);

  /// The type of this exception.
  final CancelBookExceptionType type;
}

/// The exception on [BusinessLogic].
class BookException implements Exception {
  /// The exception on [BusinessLogic].
  const BookException(final this.type, [final this.record]);

  /// The type of this exception.
  final BookExceptionType type;

  /// The record created during book if any.
  final RecordModel? record;
}

/// The provider of the [BusinessLogic].
final Provider<BusinessLogic> businessLogicProvider =
    Provider<BusinessLogic>(BusinessLogic._);

/// The provider of the main business logic.
class BusinessLogic {
  BusinessLogic._(final ProviderRefBase ref) {
    _smStretching = smStretching;
    _yClients = ref.watch(yClientsProvider);
    _smServerTimeNotifier = ref.read(smServerTimeProvider.notifier);
    smAbonements = ref.watch(smAbonementsProvider).toList(growable: false)
      ..sort();
    smStudiosOptions = ref.watch(smStudiosOptionsProvider);
    goods = ref.watch(goodsProvider).toList(growable: false)..sort();
    final activityPrice = ref.watch(smActivityPriceProvider);
    regularPrice = activityPrice.regularPrice.optionValue.toInt();
    ySalePrice = activityPrice.ySalePrice.optionValue.toInt();
  }

  late final YClientsAPI _yClients;
  late final SMStretchingAPI _smStretching;
  late final ServerTimeNotifier _smServerTimeNotifier;

  /// The current regular price of the [ActivityModel].
  late final int regularPrice;

  /// The current price with discount of the [ActivityModel].
  late final int ySalePrice;

  /// The current [SMAbonementModel] available.
  late final Iterable<SMAbonementModel> smAbonements;

  /// The current [SMStudioOptionsModel] available.
  late final Iterable<SMStudioOptionsModel> smStudiosOptions;

  /// The current [GoodModel] available.
  late final Iterable<GoodModel> goods;

  /// The current server time.
  DateTime get serverTime => _smServerTimeNotifier.state;

  /// Book the [activity] for the user.
  ///
  /// 1. Check user's deposit. If the balance is enough, book with deposit.
  /// 2. Check [abonements]. If valid abonement is found, book with it.
  /// 3. Otherwise, book regularly with cash.
  ///
  /// - [updateAndTryAgain] is a callback with created record that allows
  /// calling this method recursively.
  Future<Tuple2<RecordModel, BookResult>> book({
    required final NavigatorState navigator,
    required final UserModel user,
    required final CombinedActivityModel activity,
    required final Iterable<CombinedAbonementModel> abonements,
    required final bool useDiscount,
    final FutureOr<Tuple2<RecordModel, BookResult>> Function(RecordModel)?
        updateAndTryAgain,
    final RecordModel? prevRecord,
    final Duration? timeout,
  }) async {
    final timer = Timer(
      timeout ?? const Duration(days: 365),
      () => navigator.popUntil(Routes.root.withName),
    );

    final clients = await _yClients.getClients(
      companyId: activity.item0.companyId,
      userPhone: user.phone,
    );

    final String email;
    if (clients.isNotEmpty) {
      email = clients.first.email;
    } else {
      final client = await _yClients.createClient(
        companyId: activity.item0.companyId,
        userPhone: user.phone,
      );
      logger.i(client);
      email = client.email;
    }

    final RecordModel record;
    final Future<SMRecordModel?> Function() cancel;
    if (prevRecord != null) {
      record = prevRecord;
      cancel = () => cancelBook(
            discount: useDiscount,
            recordDate: record.date,
            recordId: record.id,
            userPhone: user.phone,
          );
    } else {
      final Tuple2<int, String> recordIdHash;
      try {
        recordIdHash = await _yClients.bookActivity(
          userEmail: email,
          userPhone: user.phone,
          userName: user.name.isNotEmpty ? user.name : user.phone,
          activityId: activity.item0.id,
          companyId: activity.item0.companyId,
        );
        logger.i(recordIdHash);
      } on DioError catch (e) {
        final dynamic error = e.error;
        if (error is YClientsException) {
          final message = error.response.data?.meta?.message ?? '';
          if (message.contains(
            'Суммарное количество мест превышает максимум для события',
          )) {
            throw const BookException(BookExceptionType.full);
          } else if (e.response?.statusCode == 409) {
            throw const BookException(BookExceptionType.alreadyApplied);
          }
        }
        throw const BookException(BookExceptionType.general);
      }

      try {
        record = await _yClients.getRecord(
          recordId: recordIdHash.item0,
          companyId: activity.item0.companyId,
        );
        logger.i(record.toJson());
      } on DioError catch (_) {
        await _yClients.deleteRecord(recordIdHash.item0, recordIdHash.item1);
        throw const BookException(BookExceptionType.general);
      }

      cancel = () => cancelBook(
            discount: useDiscount,
            recordDate: record.date,
            recordId: record.id,
            userPhone: user.phone,
          );

      if (record.documents.isEmpty) {
        await cancel();
        throw BookException(BookExceptionType.general, record);
      }

      try {
        // if (!await _smStretching.addUser(
        //   userPhone: user.phone,
        //   userEmail: email,
        //   serverTime: serverTime,
        // )) {
        //   await cancel();
        //   throw BookException(BookExceptionType.general, record);
        // }

        if (!await _smStretching.createRecord(
          documentId: record.documents.first.id,
          smRecord: SMRecordModel.fromActivity(
            activity.item0,
            recordId: record.id,
            userPhone: user.phone,
            date: serverTime,
          ),
        )) {
          await cancel();
          throw BookException(BookExceptionType.general, record);
        }
      } on DioError catch (_) {
        await cancel();
        throw BookException(BookExceptionType.general, record);
      }
    }

    Future<bool> update(
      final ActivityPaidBy paidBy, {
      final ActivityRecordStatus status = ActivityRecordStatus.paid,
      final CombinedAbonementModel? abonement,
      final int? orderId,
    }) async {
      try {
        if (paidBy != ActivityPaidBy.abonement) {
          if (!await _yClients.changeVisit(
            recordId: record.id,
            visitId: record.visitId,
            serviceId: record.services.first.id,
            regularCost: regularPrice,
            ySaleCost: useDiscount ? ySalePrice : regularPrice,
          )) {
            await cancel();
            throw BookException(BookExceptionType.general, record);
          }
        }

        await _yClients.updateRecord(
          recordId: record.id,
          activityId: activity.item0.id,
          companyId: activity.item0.companyId,
          data: <String, Object?>{
            'attendance': 2,
            'send_sms': true,
            'save_if_busy': false,
            'client': <String, Object?>{
              'name': user.phone,
              'phone': user.phone,
              'email': email,
            }
          },
        );

        if (paidBy != ActivityPaidBy.abonement) {
          await _yClients.saleByCash(
            companyId: activity.item0.companyId,
            documentId: record.documents.first.id,
            accountId: activity.item1.item2.kassaId,
            amount: useDiscount ? ySalePrice : regularPrice,
          );
        } else if (abonement != null) {
          await _yClients.saleByAbonement(
            companyId: record.companyId,
            documentId: record.documents.first.id,
            abonementId: abonement.item1.id,
            abonementNumber: abonement.item1.number,
          );
        }

        return await _smStretching.editRecord(
          SMRecordModel.fromActivity(
            activity.item0,
            recordId: record.id,
            payment: paidBy,
            userActive: status,
            date: serverTime,
            abonement: paidBy == ActivityPaidBy.abonement
                ? abonement?.item2?.documentId
                : null,
            userPhone: user.phone,
            orderId: paidBy == ActivityPaidBy.regular ? orderId : null,
          ),
        );
      } on DioError catch (e) {
        debugger(message: e.message);
        return false;
      }
    }

    /// Try to get and pay by deposit first.
    final userDeposit = await _smStretching.getUserDeposit(user.phone);
    if (userDeposit == null) {
      await cancel();
      throw BookException(BookExceptionType.general, record);
    }
    var dismiss = false;
    final updateDeposit = _smStretching.updateUserDeposit;
    if (useDiscount && userDeposit >= ySalePrice) {
      if (await updateDeposit(user.phone, userDeposit - ySalePrice)) {
        if (await update(ActivityPaidBy.deposit)) {
          return Tuple2(record, BookResult.depositDiscount);
        }
      }
    } else if (userDeposit >= regularPrice) {
      if (await updateDeposit(user.phone, userDeposit - regularPrice)) {
        if (await update(ActivityPaidBy.deposit)) {
          return Tuple2(record, BookResult.depositRegular);
        }
      }
    } else {
      /// Check if any abonement can be used for booking and book with it.
      var abonementNonMatchReason = SMAbonementNonMatchReason.none;
      for (final abonement in abonements.toList(growable: false)
        ..sort(
          (final abonementA, final abonementB) =>
              abonementA.item1.compareTo(abonementB.item1),
        )) {
        if (abonement.item1.unitedBalanceServicesCount <= 0) {
          continue;
        }
        abonementNonMatchReason = abonement.item0.matchActivity(activity.item0);
        if (abonementNonMatchReason == SMAbonementNonMatchReason.none) {
          if (await update(
            ActivityPaidBy.abonement,
            abonement: abonement,
          )) {
            return Tuple2(
              record,
              prevRecord != null
                  ? BookResult.newAbonement
                  : BookResult.abonement,
            );
          }
        }
      }

      final _smStudiosOptions = <int, SMStudioOptionsModel>{
        for (final smStudioOption in smStudiosOptions)
          smStudioOption.studioId: smStudioOption
      };
      final possibleAbonements = <SMAbonementModel, GoodModel>{
        for (final smAbonement in smAbonements.toList(growable: false)..sort())
          if (smAbonement.matchActivity(activity.item0) ==
              SMAbonementNonMatchReason.none)
            for (final good in goods.toList(growable: false)..sort())
              if (good.loyaltyAbonementTypeId == smAbonement.yId)
                if (smAbonement.service == null ||
                    good.salonId == smAbonement.service)
                  if (_smStudiosOptions.keys.contains(good.salonId))
                    smAbonement: good
      };
      if (possibleAbonements.isEmpty) {
        await cancel();
        throw const BookException(BookExceptionType.general);
      }

      /// Otherwise navigate for picking a real payment for abonement or record.
      var successBook = false;
      final result = await navigator.push(
        MaterialPageRoute<BookResult>(
          builder: (final context) {
            Future<void> pickedAnalytics({required final bool abonement}) =>
                analytics.logEvent(
                  name: FAKeys.abonementPicked,
                  parameters: <String, String>{
                    'studio': translit(activity.item1.item1.studioName),
                    'class': translit(activity.item0.service.title),
                    'trainer': translit(activity.item2.item1.trainerName),
                    'date_time': faTime(serverTime),
                    'type': abonement ? 'training_pass' : 'single_training',
                  },
                );

            return WillPopScope(
              onWillPop: () async =>
                  !successBook ? dismiss = true : successBook,
              child: PromptBookScreen(
                regularPrice: regularPrice,
                ySalePrice: ySalePrice,
                abonementPrice: possibleAbonements.keys.first.cost,
                discount: useDiscount,
                abonementNonMatchReason: abonementNonMatchReason,
                onlyFinish: true,
                onAbonement: (final context, {required final finish}) async {
                  var blockFinish = false;
                  try {
                    await Future.wait(<Future<void>>[
                      pickedAnalytics(abonement: true),
                      showPaymentPickerBottomSheet(
                        context,
                        PaymentPickerScreen(
                          allStudios: false,
                          smAbonements: possibleAbonements.keys,
                          onPayment: (
                            final email,
                            final abonement,
                            final studio,
                          ) async {
                            final good = possibleAbonements[abonement];
                            final options = _smStudiosOptions[good?.salonId];
                            if (abonement == null ||
                                good == null ||
                                options == null) {
                              return;
                            }
                            blockFinish = true;

                            try {
                              await analytics.logEvent(
                                name: FAKeys.abonementPicked,
                                parameters: <String, String>{
                                  'price': abonement.cost.toString(),
                                  'currency': 'RUB',
                                  'train_qnt': abonement.count.toString(),
                                  'class_start':
                                      abonement.time ? 'till_16.45' : 'any',
                                  'studio': abonement.service != null &&
                                          studio != null
                                      ? translit(studio.item1.studioName)
                                      : 'all',
                                  'payment_method_type': 'credit_card',
                                },
                              );

                              final payment = await payTinkoff(
                                email: email,
                                navigator: navigator,
                                companyId: good.salonId,
                                userPhone: user.phone,
                                cost: user.test ? 1 : good.cost,
                                terminalKey: options.key,
                                terminalPass: options.pass,
                                canContinue: () => timer.isActive,
                              );

                              if (!payment.item0 || payment.item1 == null) {
                                await cancel();
                                throw BookException(
                                  BookExceptionType.payment,
                                  record,
                                );
                              }

                              final result = await createAbonement(
                                abonement: abonement,
                                good: good,
                                options: options,
                                userPhone: user.phone,
                              );

                              await _smStretching.editPayment(
                                acquiring: payment.item1!,
                                serverTime: serverTime,
                                documentId: result.item0.documentId,
                                isAbonement: true,
                              );

                              successBook = true;

                              await navigator.maybePop();
                            } finally {
                              finish();
                            }
                          },
                        ),
                      ),
                    ]);
                  } finally {
                    if (!blockFinish) {
                      finish();
                    }
                  }
                },
                onRegular: (final context, {required final finish}) async {
                  var blockFinish = false;
                  try {
                    await Future.wait(<Future<void>>[
                      pickedAnalytics(abonement: false),
                      showPaymentPickerBottomSheet(
                        context,
                        PaymentPickerScreen(
                          payment: useDiscount ? ySalePrice : regularPrice,
                          onPayment: (
                            final email,
                            final abonement,
                            final studio,
                          ) async {
                            try {
                              blockFinish = true;
                              final payment = await payTinkoff(
                                cost: user.test
                                    ? 1
                                    : useDiscount
                                        ? ySalePrice
                                        : regularPrice,
                                email: email,
                                navigator: navigator,
                                companyId: activity.item0.companyId,
                                terminalKey: activity.item1.item2.key,
                                terminalPass: activity.item1.item2.pass,
                                userPhone: user.phone,
                                canContinue: () => timer.isActive,
                                recordId: record.id,
                              );

                              if (!payment.item0 || payment.item1 == null) {
                                await cancelBook(
                                  discount: useDiscount,
                                  recordDate: record.date,
                                  recordId: record.id,
                                  userPhone: user.phone,
                                );
                                throw BookException(
                                  BookExceptionType.payment,
                                  record,
                                );
                              }

                              await _smStretching.editPayment(
                                acquiring: payment.item1!,
                                serverTime: serverTime,
                                documentId: record.documents.first.id,
                                isAbonement: false,
                              );

                              if (await update(
                                ActivityPaidBy.regular,
                                orderId: int.tryParse(
                                  payment.item1?.item0.orderId ?? '',
                                ),
                              )) {
                                successBook = true;
                                await navigator.maybePop(
                                  useDiscount
                                      ? BookResult.discount
                                      : BookResult.regular,
                                );
                              }
                            } finally {
                              finish();
                            }
                          },
                        ),
                      ),
                    ]);
                  } finally {
                    if (!blockFinish) {
                      finish();
                    }
                  }
                },
              ),
            );
          },
        ),
      );
      if (result != null) {
        return Tuple2(record, result);
      } else if (updateAndTryAgain == null) {
        dismiss = true;
      }
    }

    if (!timer.isActive) {
      await cancel();
      throw BookException(BookExceptionType.timeout, record);
    } else {
      timer.cancel();
      if (dismiss) {
        await cancel();
        throw BookException(BookExceptionType.dismiss, record);
      } else if (updateAndTryAgain != null) {
        return await updateAndTryAgain(record);
      } else {
        await cancel();
        throw BookException(BookExceptionType.general, record);
      }
    }
  }

  /// Cancel the booking of the created [recordId].
  ///
  /// Returns the fetched record from SMStretching API if any.
  Future<SMRecordModel?> cancelBook({
    required final String userPhone,
    required final int recordId,
    required final DateTime recordDate,
    required final bool discount,
  }) async {
    if (recordDate.difference(serverTime).inHours < 12) {
      throw const CancelBookException(CancelBookExceptionType.timeHacking);
    }
    try {
      /// Get record in the SMStretching API.
      for (var smRecord in await _smStretching.getRecords(
        userPhone: userPhone,
        recordId: recordId,
      )) {
        smRecord = smRecord.copyWith(
          mobile: true,
          userActive: ActivityRecordStatus.canceled,
        );
        // /// Refund record payment in Tinkoff.
        // for (final payment in await _smStretching.getPayments(
        //   userPhone: user.phone,
        //   recordId: smRecord.recordId,
        //   companyId: userRecord.company.id,
        // )) {
        //   await _smStretching.editPaymentStatus(
        //     orderId: payment.orderId,
        //     serverTime: serverTime,
        //     status: 'REFUNDED',
        //     valueId: smRecord.recordId,
        //     abonement: smRecord.payment == ActivityPaidBy.abonement,
        //   );
        // }

        /// Set canceled status.
        await _smStretching.editRecord(smRecord);

        /// Refund to deposit.
        if (smRecord.payment == ActivityPaidBy.deposit ||
            smRecord.payment == ActivityPaidBy.regular) {
          final userDeposit = await _smStretching.getUserDeposit(userPhone);
          final price = discount ? ySalePrice : regularPrice;
          await _smStretching.updateUserDeposit(
            userPhone,
            userDeposit! + price,
          );
        }

        return smRecord;
      }
    } finally {
      /// Delete record in the YClients API.
      try {
        await _yClients.deleteRecord(recordId);
      } on DioError catch (e) {
        final dynamic error = e.error;
        if (error is YClientsException) {
          final message = error.response.data?.meta?.message ?? '';
          if (message.startsWith('Записи с идентификатором')) {
            throw const CancelBookException(CancelBookExceptionType.notFound);
          }
        }
        rethrow;
      }
    }
  }

  /// Create an [abonement] for the specified [userPhone].
  ///
  /// [good], [abonement] and [options] must refer to the same id.
  ///
  /// Steps:
  ///   1. Find a client in the YClients API with [userPhone].
  ///   2. Create a storage operation for the [good].
  ///   3. Create a storage transaction for the [good].
  ///   4. Create a finance transaction with the [good] actual cost.
  ///   5. Create a record in the SMStretching API.
  Future<Tuple3<StorageOperationModel, GoodTransactionModel, TransactionModel>>
      createAbonement({
    required final String userPhone,
    required final GoodModel good,
    required final SMAbonementModel abonement,
    required final SMStudioOptionsModel options,
  }) async {
    final clients = await _yClients.getClients(
      companyId: good.salonId,
      userPhone: userPhone,
    );

    final int clientId;
    if (clients.isNotEmpty) {
      clientId = clients.first.id;
    } else {
      final client = await _yClients.createClient(
        companyId: good.salonId,
        userPhone: userPhone,
      );
      clientId = client.id;
    }

    /// Create the storage operation of selling an
    /// abonement.
    final currentTime = serverTime;
    final storageOperation = await _yClients.createStorageOperation(
      clientId: clientId,
      companyId: good.salonId,
      storageId: options.skladId,
      masterId: options.kassirMobileId,
      goodId: good.goodId,
      goodCost: good.cost,
      serverTime: currentTime,
    );

    /// Create abonement transaction.
    final goodSpecialNumber = 'm_${storageOperation.documentId}'
        '${currentTime.hour}${currentTime.minute}${currentTime.second}';
    final goodTransaction = await _yClients.createTransaction(
      clientId: clientId,
      companyId: good.salonId,
      masterId: options.kassirMobileId,
      goodId: good.goodId,
      goodCost: good.cost,
      documentId: storageOperation.documentId,
      goodSpecialNumber: goodSpecialNumber,
    );

    /// Create finance transaction of selling an
    /// abonement.
    final transaction = await _yClients.saleByCash(
      amount: good.cost,
      companyId: good.salonId,
      accountId: options.kassaId,
      documentId: storageOperation.document.id,
    );

    final _serverTime = serverTime;
    final dateEnd = DateTime(
      _serverTime.year,
      _serverTime.month,
      _serverTime.day,
      23,
      59,
      59,
    ).add(Duration(days: abonement.ySrok));

    /// Add abonement to the SMStretching API.
    await _smStretching.createAbonement(
      companyId: good.salonId,
      documentId: storageOperation.document.id,
      abonementId: abonement.yId,
      userPhone: userPhone,
      createdAt: serverTime,
      dateEnd: dateEnd,
    );

    return Tuple3(storageOperation, goodTransaction, transaction);
  }

  /// Updates a client in the YClients API.
  ///
  /// Steps:
  ///   1. Get client from YClients for the [companyId].
  ///   2. If a client was not returned, create a client in the API.
  ///   3. Edit the client in the YClients API.
  Future<void> updateClient({
    required final int companyId,
    required final String userPhone,
    final String name = '',
    final String email = '',
  }) async {
    final clients = await _yClients.getClients(
      companyId: companyId,
      userPhone: userPhone,
    );

    final int clientId;
    if (clients.isNotEmpty) {
      clientId = clients.first.id;
    } else {
      final client = await _yClients.createClient(
        companyId: companyId,
        userPhone: userPhone,
        email: email,
        name: name,
      );
      clientId = client.id;
    }

    await _yClients.editClient(
      companyId: companyId,
      clientId: clientId,
      email: email,
      name: name,
      phone: userPhone,
    );
  }

  /// Initialize and proceed the payment with Tinkoff.
  ///
  /// - [navigator] is found in [BuildContext].
  Future<Tuple2<bool, WebViewAcquiring?>> payTinkoff({
    required final NavigatorState navigator,
    required final int companyId,
    required final String email,
    required final String userPhone,
    required final int cost,
    required final String terminalKey,
    required final String terminalPass,
    final int? recordId,
    final FutureOr<bool> Function()? canContinue,
  }) async {
    final orderId = await _smStretching.createPayment(
      recordId: recordId,
      companyId: companyId,
      userPhone: userPhone,
    );
    bool? returnValue;
    WebViewAcquiring? acquiring;
    if (orderId != null) {
      acquiring = await _initAcquiring(
        email: email,
        userPhone: userPhone,
        orderId: orderId.toString(),
        amount: cost,
        terminalKey: terminalKey,
        password: terminalPass,
      );
      var firstTry = true;
      var retry = true;
      while (retry && (await canContinue?.call() ?? true)) {
        final route = MaterialPageRoute<bool>(
          builder: (final context) => WebViewAcquiringScreen(acquiring!),
        );
        returnValue = firstTry
            ? await navigator.pushReplacement(route)
            : await navigator.push(route);

        firstTry = false;
        if (returnValue ?? false) {
          retry = false;
        } else if (await canContinue?.call() ?? true) {
          final _retry = await navigator.push(
            MaterialPageRoute<bool>(
              builder: (final context) => ResultBookScreen(
                showBackButton: true,
                title: BookExceptionType.payment.title,
                body: BookExceptionType.payment.info,
                button: BookExceptionType.payment.button,
              ),
            ),
          );
          retry = _retry ?? false;
        }
      }
    }
    if (acquiring?.item0.amount != null && (returnValue ?? false)) {
      await analytics.logEvent(
        name: FAKeys.purchase,
        parameters: <String, String>{
          'value': (acquiring!.item0.amount! ~/ 100).toString(),
          'currency': 'RUB',
          'TRANSACTION_ID': acquiring.item0.orderId,
        },
      );
    }
    return Tuple2(returnValue ?? false, acquiring);
  }

  /// Creates payment url to proceed with the payment.
  ///
  /// Returns an inited request and inited response.
  Future<WebViewAcquiring> _initAcquiring({
    required final String userPhone,
    required final String terminalKey,
    required final String password,
    required final String orderId,
    required final String email,
    required final int amount,
  }) async {
    final acquiring = TinkoffAcquiring(
      TinkoffAcquiringConfig(
        debug: false,
        password: password,
        terminalKey: terminalKey,
      ),
    );

    final concatenated =
        (amount * 100).toString() + orderId + password + terminalKey;
    final request = InitRequest(
      orderId: orderId,
      customerKey: userPhone,
      amount: amount * 100,
      language: Language.ru,
      payType: PayType.one,
      successUrl: 'https://success',
      failUrl: 'https://fail',
      recurrent: 'N',
      data: <String, String>{'Email': email, 'Phone': '+$userPhone'},
      signToken: sha256.convert(utf8.encode(concatenated)).toString(),
    );
    return Tuple2(request, await acquiring.init(request));
  }
}

/// Refreshes all api providers.
Future<void> refreshAllProviders(final ProviderContainer container) async {
  final serverTime = await smStretching.getServerTime();
  final activityPrice = await smStretching.getActivityPrice();
  if (serverTime == null || activityPrice == null) {
    return;
  }
  container.updateOverrides(<Override>[
    smServerTimeProvider.overrideWithValue(ServerTimeNotifier(serverTime)),
    smActivityPriceProvider.overrideWithValue(activityPrice)
  ]);
  container.read(errorProvider).state = null;
  container.read(splashProvider).state = true;
  await container.read(smStudiosOptionsProvider.notifier).refresh();
  try {
    await Future.wait(<Future<Object?>>[
      /// YClients API
      container.read(studiosProvider.notifier).refresh(),
      container.read(trainersProvider.notifier).refresh(),
      container.read(scheduleProvider.notifier).refresh(),
      container.read(goodsProvider.notifier).refresh(),
      // container.read(userAbonementsProvider.notifier).refresh(),
      // container.read(userRecordsProvider.notifier).refresh(),

      /// SMStretching API
      container.read(smAdvertismentsProvider.notifier).refresh(),
      container.read(smStoriesProvider.notifier).refresh(),
      container.read(smAbonementsProvider.notifier).refresh(),
      container.read(smStudiosProvider.notifier).refresh(),
      container.read(smTrainersProvider.notifier).refresh(),
      container.read(smClassesGalleryProvider.notifier).refresh(),
      // container.read(smUserDepositProvider.future),
      // container.read(smUserAbonementsProvider.notifier).refresh(),
    ]);
  } finally {
    container.read(splashProvider).state = false;
  }
}
