import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'clinic.dart';
import 'nearby_clinics_card.dart';
import 'nearby_clinics_provider.dart';

class ClinicsPage extends ConsumerStatefulWidget {
  const ClinicsPage({super.key});

  @override
  ConsumerState<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends ConsumerState<ClinicsPage> {
  final _map = MapController();
  String? _selectedId;

  void _select(Clinic c) {
    setState(() => _selectedId = c.id);
    _map.move(LatLng(c.latitude, c.longitude), 15);
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final clinics = ref.watch(nearbyClinicsProvider);
    final user = ref.watch(userPositionProvider).maybeWhen(
          data: (p) => LatLng(p.latitude, p.longitude),
          orElse: () => const LatLng(-7.9797, 112.6304),
        );

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Nearby clinics'),
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: clinics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => retryNearbyClinics(ref, error),
            child: const Text('Try again'),
          ),
        ),
        data: (list) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: SizedBox(
                  height: 280,
                  child: _ClinicsMap(
                    controller: _map,
                    userLocation: user,
                    clinics: list,
                    selectedId: _selectedId,
                    onSelect: _select,
                  ),
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('No clinics found near you yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        0,
                        AppSpacing.gutter,
                        AppSpacing.xl,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => ClinicTile(
                        clinic: list[i],
                        selected: list[i].id == _selectedId,
                        onTap: () => _select(list[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicsMap extends StatelessWidget {
  const _ClinicsMap({
    required this.controller,
    required this.userLocation,
    required this.clinics,
    required this.selectedId,
    required this.onSelect,
  });

  final MapController controller;
  final LatLng userLocation;
  final List<Clinic> clinics;
  final String? selectedId;
  final ValueChanged<Clinic> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: 13,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

          userAgentPackageName: 'com.example.berseri',
        ),
        MarkerLayer(
          markers: [
            // Posisi user
            Marker(
              point: userLocation,
              width: 22,
              height: 22,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            // Klinik
            for (final c in clinics)
              Marker(
                point: LatLng(c.latitude, c.longitude),
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => onSelect(c),
                  child: Icon(
                    Icons.location_on,
                    size: c.id == selectedId ? 44 : 36,
                    color: c.id == selectedId
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
        // Wajib: atribusi OpenStreetMap
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}