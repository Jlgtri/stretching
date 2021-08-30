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

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = Theme.of(context);
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
    final mapController = useRef<GoogleMapController?>(null);
    final onMap = useState<bool>(false);
    return PageTransitionSwitcher(
      reverse: !onMap.value,
      duration: const Duration(milliseconds: 500),
      layoutBuilder: (final entries) => Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(55.751244, 37.618423),
              zoom: 14,
            ),
            compassEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: mapMarker.when(
              data: (final marker) => <Marker>{
                for (final studio in studios)
                  Marker(
                    markerId: MarkerId(studio.id.toString()),
                    position:
                        LatLng(studio.coordinateLat, studio.coordinateLon),
                    flat: true,
                    icon: marker,
                    onTap: () {},
                  )
              },
              loading: () => <Marker>{},
              error: (final e, final st) => <Marker>{},
            ),
            onMapCreated: (final controller) async {
              final style = await ref.read(mapStyleProvider.future);
              await controller.setMapStyle(style);
              mapController.value = controller;
            },
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
                  itemCount: studios.length,
                  itemBuilder: (final context, final index) {
                    return StudioCard(studio: studios.elementAt(index));
                  },
                ),
              ),
            )
          : null,
    );
  }
}

/// The card for the [StudiosScreen].
class StudioCard extends ConsumerWidget {
  /// The card for the [StudiosScreen].
  const StudioCard({required final this.studio, final Key? key})
      : super(key: key);

  /// The studio in the YClients API.
  final CompanyModel studio;

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CachedNetworkImage(
        imageUrl: smStudio.mediaGallerySite.isNotEmpty
            ? smStudio.mediaGallerySite.first.url
            : studio.photos.isNotEmpty
                ? studio.photos.first
                : studio.logo,
        imageBuilder: (final context, final imageProvider) {
          return CircleAvatar(
            radius: 24,
            foregroundImage: imageProvider,
          );
        },
        placeholder: (final context, final url) =>
            const CircularProgressIndicator(),
        errorWidget: (final context, final url, final dynamic error) =>
            const FontIcon(FontIconData(IconsCG.logo)),
      ),
      title: Text(studio.title, style: theme.textTheme.bodyText1),
      isThreeLine: true,
      subtitle: Text.rich(
        TextSpan(
          text: studio.address,
          style: theme.textTheme.bodyText2,
          children: <InlineSpan>[
            TextSpan(
              text: currentLocation.when<String>(
                data: (final position) {
                  final distance = GeolocatorPlatform.instance.distanceBetween(
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
      ),
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(
      properties..add(DiagnosticsProperty<CompanyModel>('studio', studio)),
    );
  }
}
