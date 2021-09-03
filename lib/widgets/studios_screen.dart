import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stretching/generated/icons.g.dart';
import 'package:stretching/generated/localization.g.dart';
import 'package:stretching/models/map_info_windows_options.dart';
import 'package:stretching/models_smstretching/sm_studio_model.dart';
import 'package:stretching/models_yclients/company_model.dart';
import 'package:stretching/providers/other_providers.dart';
import 'package:stretching/providers/smstretching_providers.dart';
import 'package:stretching/providers/yclients_providers.dart';
import 'package:stretching/style.dart';
import 'package:stretching/widgets/components/font_icon.dart';
import 'package:stretching/widgets/navigation/navigation_root.dart';

/// The screen for the [NavigationScreen.studios].
class StudiosScreen extends HookConsumerWidget {
  /// The screen for the [NavigationScreen.studios].
  const StudiosScreen({final Key? key}) : super(key: key);

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(55.751244, 37.618423),
    zoom: 12.5,
  );

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final devicePixelRatio =
        Platform.isAndroid ? mediaQuery.devicePixelRatio : 1;

    final studios = ref.watch(studiosProvider);
    final mapMarker = ref.watch(
      mapMarkerProvider(
        FontIconData(
          IconsCG.pin,
          color: theme.colorScheme.onSurface,
          height: (20 + 20 / 3) * 4,
        ),
      ),
    );
    final mapController = useState<GoogleMapController?>(null);
    final infoWindowOptions = useState<InfoWindowOptions?>(null);
    final screenCoordinates = useState<ScreenCoordinate?>(null);
    final onMap = useState<bool>(false);

    Future<void> moveToStudioOnMap(final StudioModel studio) async {
      final options = InfoWindowOptions(
        coordinates: LatLng(
          studio.coordinateLat,
          studio.coordinateLon,
        ),
        offset: const Offset(-40, 20),
        size: const Size(196, 42),
      );
      if (infoWindowOptions.value != options) {
        final controller = mapController.value;
        if (controller != null) {
          infoWindowOptions.value = screenCoordinates.value = null;
          await Future<void>.delayed(
            const Duration(milliseconds: 350),
          );
          infoWindowOptions.value = options;
          screenCoordinates.value =
              await controller.getScreenCoordinate(options.coordinates);
        }
      }
    }

    Future<void> onMainStudioCardTap(final StudioModel studio) async {
      onMap.value = true;
      await mapController.value?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(studio.coordinateLat, studio.coordinateLon),
            zoom: _initialCameraPosition.zoom,
            bearing: _initialCameraPosition.bearing,
            tilt: _initialCameraPosition.tilt,
          ),
        ),
      );
      await mapController.value
          ?.showMarkerInfoWindow(MarkerId(studio.id.toString()));
      await moveToStudioOnMap(studio);
    }

    Future<void> openStudioPage(
      final StudioModel studio,
      final SMStudioModel smStudio,
    ) async {}

    return PageTransitionSwitcher(
      reverse: !onMap.value,
      duration: const Duration(milliseconds: 500),
      layoutBuilder: (final entries) => Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            compassEnabled: false,
            // myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            // onCameraMoveStarted: () {
            //   infoWindowOffset.value = Offset.zero;
            //   infoWindowOptions.value = null;
            // },
            markers: mapMarker.when(
              data: (final marker) => <Marker>{
                for (final studio in studios)
                  Marker(
                    markerId: MarkerId(studio.id.toString()),
                    position:
                        LatLng(studio.coordinateLat, studio.coordinateLon),
                    flat: true,
                    icon: marker,
                    onTap: () => moveToStudioOnMap(studio),
                  )
              },
              loading: () => <Marker>{},
              error: (final e, final st) => <Marker>{},
            ),
            onTap: (final position) =>
                infoWindowOptions.value = screenCoordinates.value = null,
            onCameraMove: (final position) async {
              final info = infoWindowOptions.value;
              final controller = mapController.value;
              if (info != null && controller != null) {
                screenCoordinates.value =
                    await controller.getScreenCoordinate(info.coordinates);
              }
            },
            onMapCreated: (final controller) async {
              final style = await ref.read(mapStyleProvider.future);
              await controller.setMapStyle(style);
              mapController.value = controller;
            },
          ),

          /// Location FAB
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton.small(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                final location = await ref.read(locationProvider.last);
                await mapController.value?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(location.latitude, location.longitude),
                      zoom: _initialCameraPosition.zoom,
                      bearing: _initialCameraPosition.bearing,
                      tilt: _initialCameraPosition.tilt,
                    ),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              child: const FontIcon(
                FontIconData(IconsCG.mapLocation, height: 14),
              ),
            ),
          ),

          /// The custom info window.
          if (infoWindowOptions.value != null &&
              screenCoordinates.value != null)
            Positioned(
              left: (screenCoordinates.value!.x / devicePixelRatio) -
                  (infoWindowOptions.value!.offset.dx +
                      infoWindowOptions.value!.size.width / 2),
              top: (screenCoordinates.value!.y / devicePixelRatio) -
                  (infoWindowOptions.value!.offset.dy +
                      infoWindowOptions.value!.size.height),
              child: SizedBox.fromSize(
                size: infoWindowOptions.value!.size,
                child: StudioCard(
                  onMap: true,
                  onTap: openStudioPage,
                  studio: studios.firstWhere((final studio) {
                    final coordinates = infoWindowOptions.value!.coordinates;
                    return studio.coordinateLat.toStringAsFixed(6) ==
                            coordinates.latitude.toStringAsFixed(6) &&
                        studio.coordinateLon.toStringAsFixed(6) ==
                            coordinates.longitude.toStringAsFixed(6);
                  }),
                ),
              ),
            ),

          /// Other Content
          ...entries,

          /// Switcher
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const FontIcon(FontIconData(IconsCG.list)),
                    label: Text(TR.studiosViewList.tr()),
                    style: (onMap.value
                            ? TextButtonStyle.light.fromTheme(theme)
                            : TextButtonStyle.dark.fromTheme(theme))
                        .copyWith(
                      visualDensity: VisualDensity.compact,
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    onPressed: () => onMap.value ? onMap.value = false : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const FontIcon(FontIconData(IconsCG.pinOutline)),
                    label: Text(TR.studiosViewMap.tr()),
                    style: (onMap.value
                            ? TextButtonStyle.dark.fromTheme(theme)
                            : TextButtonStyle.light.fromTheme(theme))
                        .copyWith(
                      visualDensity: VisualDensity.compact,
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    onPressed: () => !onMap.value ? onMap.value = true : null,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      transitionBuilder: (
        final child,
        final animation,
        final secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      child: !onMap.value
          ? Material(
              color: theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemExtent: 88,
                  itemCount: studios.length,
                  itemBuilder: (final context, final index) {
                    final studio = studios.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StudioCard(
                        studio: studio,
                        onTap: (final studio, final smStudio) =>
                            onMainStudioCardTap(studio),
                        onAvatarTap: openStudioPage,
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }
}

/// The callback on a [StudioModel] and a [SMStudioModel].
typedef OnStudio = void Function(StudioModel studio, SMStudioModel smStudio);

/// The card for the [StudiosScreen].
class StudioCard extends ConsumerWidget {
  /// The card for the [StudiosScreen].
  const StudioCard({
    required final this.studio,
    final this.onTap,
    final this.onAvatarTap,
    final this.onMap = false,
    final Key? key,
  }) : super(key: key);

  /// The studio in the YClients API.
  final StudioModel studio;

  /// The callback to call on tap of this card.
  final OnStudio? onTap;

  /// The callback to call on tap of the avatar of this card.
  final OnStudio? onAvatarTap;

  /// If this is the on-map version of this card.
  final bool onMap;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocation = ref.watch(locationProvider);
    final smStudio = ref.watch(
      smStudiosProvider.select((final smStudios) {
        return smStudios.firstWhere((final smStudio) {
          return smStudio.studioYId == studio.id;
        });
      }),
    );
    return Material(
      elevation: onMap ? 10 : 0,
      borderRadius: BorderRadius.circular(onMap ? 4 : 8),
      child: ListTile(
        onTap: () => onTap?.call(studio, smStudio),
        dense: onMap,
        enableFeedback: true,
        contentPadding: EdgeInsets.symmetric(horizontal: onMap ? 8 : 16),
        visualDensity: onMap ? VisualDensity.compact : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(onMap ? 4 : 8),
          side: onMap ? const BorderSide() : BorderSide.none,
        ),
        tileColor: theme.colorScheme.surface,
        selectedTileColor: theme.colorScheme.surface,
        focusColor: theme.colorScheme.surface.withOpacity(2 / 3),
        hoverColor: theme.colorScheme.surface.withOpacity(2 / 3),
        horizontalTitleGap: onMap ? 8 : null,
        leading: CachedNetworkImage(
          imageUrl: smStudio.mediaGallerySite.isNotEmpty
              ? smStudio.mediaGallerySite.first.url
              : studio.photos.isNotEmpty
                  ? studio.photos.first
                  : studio.logo,
          alignment: Alignment.topCenter,
          imageBuilder: (final context, final imageProvider) {
            return IgnorePointer(
              ignoring: onAvatarTap == null,
              child: MaterialButton(
                onPressed: () => onAvatarTap?.call(studio, smStudio),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                minWidth: (onMap ? 16 : 24) * 2,
                child: CircleAvatar(
                  radius: onMap ? 16 : 24,
                  foregroundImage: imageProvider,
                ),
              ),
            );
          },
          placeholder: (final context, final url) =>
              const CircularProgressIndicator(),
          errorWidget: (final context, final url, final dynamic error) =>
              const FontIcon(FontIconData(IconsCG.logo)),
        ),
        title: Text.rich(
          TextSpan(
            text: studio.title,
            style: theme.textTheme.headline6
                ?.copyWith(fontSize: onMap ? 12 : null),
            children: <InlineSpan>[
              if (onMap) ...[
                const TextSpan(text: '\n', style: TextStyle(fontSize: 16)),
                TextSpan(
                  text: studio.address,
                  style: theme.textTheme.bodyText2
                      ?.copyWith(fontSize: onMap ? 10 : null),
                ),
              ]
            ],
          ),
          // softWrap: !onMap,
          maxLines: onMap ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: !onMap,
        subtitle: !onMap
            ? Text.rich(
                TextSpan(
                  text: studio.address,
                  children: <InlineSpan>[
                    if (!onMap)
                      TextSpan(
                        text: currentLocation.when<String>(
                          data: (final position) {
                            final distance =
                                GeolocatorPlatform.instance.distanceBetween(
                              position.latitude,
                              position.longitude,
                              studio.coordinateLat,
                              studio.coordinateLon,
                            );
                            if (distance < 10) {
                              // ignore: prefer_interpolation_to_compose_strings
                              return '\n' + TR.studiosLocationOn.tr();
                            } else if (distance < 1000) {
                              // ignore: prefer_interpolation_to_compose_strings
                              return '\n' +
                                  TR.studiosLocationM.tr(
                                    args: <String>[
                                      num.parse(
                                        distance.toStringAsFixed(
                                          distance < 100 ? 1 : 0,
                                        ),
                                      ).toString()
                                    ],
                                  );
                            } else {
                              final distanceInKm = distance / 1000;
                              // ignore: prefer_interpolation_to_compose_strings
                              return '\n' +
                                  TR.studiosLocationKm.tr(
                                    args: <String>[
                                      num.parse(
                                        distanceInKm.toStringAsFixed(
                                          distanceInKm < 10
                                              ? 2
                                              : distanceInKm < 100
                                                  ? 1
                                                  : 0,
                                        ),
                                      ).toString()
                                    ],
                                  );
                            }
                          },
                          loading: () => '',
                          error: (final e, final st) => '',
                        ),
                        style: theme.textTheme.subtitle2,
                      )
                  ],
                ),
                softWrap: !onMap,
                style: theme.textTheme.bodyText2
                    ?.copyWith(fontSize: onMap ? 10 : null),
                maxLines: onMap ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FontIcon(
              FontIconData(
                IconsCG.angleRight,
                height: onMap ? 14 : 20,
              ),
            ),
            if (!onMap) const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties
        ..add(DiagnosticsProperty<CompanyModel>('studio', studio))
        ..add(ObjectFlagProperty<OnStudio?>.has('onTap', onTap))
        ..add(ObjectFlagProperty<OnStudio?>.has('onAvatarTap', onAvatarTap))
        ..add(DiagnosticsProperty<bool>('onMap', onMap)),
    );
  }
}
