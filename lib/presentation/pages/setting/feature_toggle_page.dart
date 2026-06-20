import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../data/model/setting/feature_toggle_model.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_bloc.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_event.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_state.dart';

@RoutePage()
class FeatureTogglePage extends StatefulWidget implements AutoRouteWrapper {
  const FeatureTogglePage({Key? key}) : super(key: key);

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator.get<FeatureToggleBloc>()..add(FetchFeatureToggles()),
      child: this,
    );
  }

  @override
  _FeatureTogglePageState createState() => _FeatureTogglePageState();
}

class _FeatureTogglePageState extends State<FeatureTogglePage> {
  @override
  void initState() {
    super.initState();
    // context.read<FeatureToggleBloc>().add(FetchFeatureToggles()); // Sudah dipanggil di wrappedRoute
  }

  void _onToggleChanged(FeatureToggleModel toggle, bool value) {
    if (toggle.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modul ${toggle.name} adalah modul inti dan tidak dapat dimatikan.')),
      );
      return;
    }
    context.read<FeatureToggleBloc>().add(UpdateFeatureToggle(key: toggle.key, isActive: value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Fitur & Modul'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<FeatureToggleBloc, FeatureToggleState>(
        listener: (context, state) {
          if (state is FeatureToggleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is FeatureToggleInitial || state is FeatureToggleLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeatureToggleLoaded) {
            if (state.toggles.isEmpty) {
              return const Center(child: Text('Belum ada pengaturan fitur.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeatureToggleBloc>().add(FetchFeatureToggles());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.toggles.length,
                itemBuilder: (context, index) {
                  final module = state.toggles[index];
                  return _buildModuleCard(context, module, state);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, FeatureToggleModel module, FeatureToggleLoaded state) {
    final bool isUpdating = state is FeatureToggleUpdating && state.updatingKey == module.key;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              module.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: module.description != null ? Text(module.description!) : null,
            trailing: isUpdating
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Tooltip(
                    message: module.isLocked ? 'Modul inti tidak dapat dimatikan' : '',
                    child: Switch(
                      value: module.isActive,
                      onChanged: module.isLocked ? null : (val) => _onToggleChanged(module, val),
                    ),
                  ),
          ),
          
          // Children Features
          if (module.children.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: module.children.map((child) {
                  final bool isChildUpdating = state is FeatureToggleUpdating && state.updatingKey == child.key;
                  // Efektif status child juga bergantung pada parent
                  final bool effectiveIsActive = child.isActive && module.isActive;

                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
                    title: Text(
                      child.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: module.isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    trailing: isChildUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: effectiveIsActive,
                            // Jika parent mati, disable switch anak
                            onChanged: (!module.isActive || child.isLocked)
                                ? null
                                : (val) => _onToggleChanged(child, val),
                          ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
