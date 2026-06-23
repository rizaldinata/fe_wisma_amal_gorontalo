import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intl/intl.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/model/setting/feature_toggle_model.dart';
import '../../../domain/entity/setting/midtrans_fee_config_entity.dart';
import '../../../domain/entity/setting/midtrans_method_entity.dart';
import '../../bloc/midtrans_fee/midtrans_fee_cubit.dart';
import '../../bloc/payment_method_setting/payment_method_setting_cubit.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_bloc.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_event.dart';
import '../../bloc/setting/feature_toggle/feature_toggle_state.dart';
import '../../bloc/setting/setting_bloc.dart';
import '../../bloc/setting/setting_event.dart';
import '../../bloc/setting/setting_state.dart';

@RoutePage()
class FeatureTogglePage extends StatefulWidget {
  const FeatureTogglePage({Key? key}) : super(key: key);

  @override
  _FeatureTogglePageState createState() => _FeatureTogglePageState();
}

class _FeatureTogglePageState extends State<FeatureTogglePage> {
  late PaymentMethodSettingCubit _paymentCubit;
  late MidtransFeeCubit _midtransFeeCubit;
  late SettingBloc _settingBloc;

  final Set<String> _jenisAktif = {};
  static const _allJenis = ['listrik', 'air', 'wifi'];
  static const _jenisLabel = {'listrik': 'Listrik', 'air': 'Air', 'wifi': 'WiFi'};

  @override
  void initState() {
    super.initState();
    context.read<FeatureToggleBloc>().add(FetchFeatureToggles());
    _paymentCubit = serviceLocator.get<PaymentMethodSettingCubit>();
    _paymentCubit.load();
    _midtransFeeCubit = serviceLocator.get<MidtransFeeCubit>();
    _midtransFeeCubit.load();
    _settingBloc = serviceLocator.get<SettingBloc>();
    _settingBloc.add(FetchSettingsEvent());
  }

  @override
  void dispose() {
    _paymentCubit.close();
    _midtransFeeCubit.close();
    // SettingBloc adalah lazySingleton, tidak di-close di sini
    super.dispose();
  }

  void _updateJenisFromSettings(Map<String, dynamic> settings) {
    final rawJenis = settings['pengeluaran_tetap_jenis_aktif'];
    setState(() {
      _jenisAktif.clear();
      if (rawJenis is List) {
        _jenisAktif.addAll(rawJenis.map((e) => e.toString()));
      }
    });
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

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.orange.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _paymentCubit),
        BlocProvider.value(value: _midtransFeeCubit),
        BlocProvider.value(value: _settingBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<FeatureToggleBloc, FeatureToggleState>(
            listener: (context, state) {
              if (state is FeatureToggleError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<SettingBloc, SettingState>(
            listener: (context, state) {
              if (state is SettingLoaded) {
                _updateJenisFromSettings(state.entity.settings);
              } else if (state is SettingUpdateSuccess) {
                _updateJenisFromSettings(state.entity.settings);
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Pengaturan Fitur & Modul'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: BlocBuilder<FeatureToggleBloc, FeatureToggleState>(
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
        ),
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, FeatureToggleModel module, FeatureToggleLoaded state) {
    final bool isUpdating = state is FeatureToggleUpdating && state.updatingKey == module.key;
    final bool isDark = AppTheme.isDark(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              module.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: module.description != null ? Text(module.description!) : null,
            trailing: isUpdating
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Tooltip(
                    message: module.isLocked ? 'Modul inti tidak dapat dimatikan' : '',
                    child: Switch(
                      value: module.isActive,
                      onChanged: module.isLocked ? null : (val) => _onToggleChanged(module, val),
                    ),
                  ),
          ),
          if (module.children.any((c) => !c.isLocked))
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
                children: [
                  for (final child in module.children.where((c) => !c.isLocked)) ...[
                    _buildChildTile(child, module, state),
                    // Sub-cards muncul tepat di bawah toggle masing-masing
                    if (child.key == 'finance_midtrans' && child.isActive && module.isActive) ...[
                      _buildMidtransPaymentSubCard(isDark),
                      _buildMidtransFeeSubCard(isDark),
                    ],
                    if (child.key == 'finance_fixed_expense' && child.isActive && module.isActive) ...[
                      _buildFixedExpenseSubCard(isDark),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildTile(FeatureToggleModel child, FeatureToggleModel module, FeatureToggleLoaded state) {
    final bool isChildUpdating = state is FeatureToggleUpdating && state.updatingKey == child.key;
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
      subtitle: child.description != null
          ? Text(
              child.description!,
              style: TextStyle(
                fontSize: 12,
                color: module.isActive ? Colors.grey[600] : Colors.grey[400],
              ),
            )
          : null,
      trailing: isChildUpdating
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Switch(
              value: effectiveIsActive,
              onChanged: (!module.isActive || child.isLocked)
                  ? null
                  : (val) => _onToggleChanged(child, val),
            ),
    );
  }

  Widget _buildFixedExpenseSubCard(bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final primaryBg = isDark ? AppColorsDark.primaryLight : AppColorsLight.primaryLight;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: warningColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.bolt_outlined, color: warningColor, size: 20),
              title: const Text('Jenis Utilitas Aktif',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Pilih minimal satu jenis utilitas yang akan dipantau setiap bulan.',
                  style: TextStyle(fontSize: 11)),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<SettingBloc, SettingState>(
                builder: (context, settingState) {
                  final isSaving = settingState is SettingLoading;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_jenisAktif.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: warningBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: warningBorder),
                          ),
                          child: Row(children: [
                            Icon(Icons.warning_amber_rounded, color: warningColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              'Pilih minimal satu jenis utilitas.',
                              style: TextStyle(fontSize: 11, color: warningColor),
                            )),
                          ]),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allJenis.map((jenis) {
                          final isSelected = _jenisAktif.contains(jenis);
                          return FilterChip(
                            label: Text(_jenisLabel[jenis] ?? jenis,
                                style: const TextStyle(fontSize: 13)),
                            selected: isSelected,
                            selectedColor: primaryBg,
                            checkmarkColor: primaryColor,
                            side: BorderSide(color: isSelected ? primaryColor : borderColor),
                            onSelected: isSaving
                                ? null
                                : (selected) {
                                    if (!selected && _jenisAktif.length <= 1) {
                                      _showWarningSnackBar(
                                          'Minimal satu jenis utilitas harus aktif.');
                                      return;
                                    }
                                    final newSet = Set<String>.from(_jenisAktif);
                                    if (selected) newSet.add(jenis);
                                    else newSet.remove(jenis);
                                    context.read<SettingBloc>().add(
                                      UpdateSettingsEvent({
                                        'pengeluaran_tetap_jenis_aktif': newSet.toList(),
                                      }),
                                    );
                                  },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMidtransPaymentSubCard(bool isDark) {
    final activeColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
    final activeBg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
    final activeBorder = isDark ? AppColorsDark.statusDoneBorder : AppColorsLight.statusDoneBorder;
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;
    final warningBorder = isDark ? AppColorsDark.statusWaitingBorder : AppColorsLight.statusWaitingBorder;
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final cancelBg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: activeColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.payment_rounded, color: activeColor, size: 20),
              title: const Text('Metode Pembayaran Midtrans',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Pilih metode yang tersedia untuk penghuni. Toggle tersimpan otomatis.',
                  style: TextStyle(fontSize: 11)),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocConsumer<PaymentMethodSettingCubit, PaymentMethodSettingState>(
                listener: (context, pmState) {
                  if (pmState is PaymentMethodSettingSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(Icons.check_circle, color: activeColor, size: 18),
                        const SizedBox(width: 10),
                        Text('Metode pembayaran diperbarui', style: TextStyle(color: activeColor)),
                      ]),
                      backgroundColor: activeBg,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ));
                  } else if (pmState is PaymentMethodSettingError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(Icons.error_outline, color: cancelColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Gagal: ${pmState.message}', style: TextStyle(color: cancelColor))),
                      ]),
                      backgroundColor: cancelBg,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ));
                  }
                },
                builder: (context, pmState) {
                  if (pmState is PaymentMethodSettingInitial || pmState is PaymentMethodSettingLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  }
                  if (pmState is PaymentMethodSettingError) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Gagal memuat metode: ${pmState.message}',
                          style: TextStyle(color: cancelColor)),
                    );
                  }

                  final List<MidtransMethodEntity> methods;
                  if (pmState is PaymentMethodSettingLoaded) {
                    methods = pmState.methods;
                  } else if (pmState is PaymentMethodSettingSaving) {
                    methods = pmState.methods;
                  } else if (pmState is PaymentMethodSettingSaved) {
                    methods = pmState.methods;
                  } else {
                    methods = [];
                  }

                  final isSavingPm = pmState is PaymentMethodSettingSaving;
                  final enabledCount = methods.where((m) => m.enabled).length;
                  final showWarning = methods.isNotEmpty && enabledCount == 0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showWarning)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: warningBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: warningBorder),
                          ),
                          child: Row(children: [
                            Icon(Icons.warning_amber_rounded, color: warningColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              'Tidak ada metode yang aktif. Aktifkan minimal satu metode.',
                              style: TextStyle(fontSize: 11, height: 1.4, color: warningColor),
                            )),
                          ]),
                        ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          mainAxisExtent: 50,
                        ),
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: method.enabled ? activeBg : surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: method.enabled ? activeBorder : borderColor),
                            ),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              dense: true,
                              title: Text(
                                method.label,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              value: method.enabled,
                              activeColor: activeColor,
                              onChanged: isSavingPm
                                  ? null
                                  : (val) {
                                      if (!val && enabledCount <= 1 && method.enabled) {
                                        _showWarningSnackBar('Minimal satu metode harus aktif selama Midtrans dinyalakan.');
                                        return;
                                      }
                                      final enabledCodes = methods
                                          .where((m) => m.code == method.code ? val : m.enabled)
                                          .map((m) => m.code)
                                          .toList();
                                      context.read<PaymentMethodSettingCubit>().save(enabledCodes);
                                    },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMidtransFeeSubCard(bool isDark) {
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final cancelColor = isDark ? AppColorsDark.statusCancelled : AppColorsLight.statusCancelled;
    final cancelBg = isDark ? AppColorsDark.statusCancelledBg : AppColorsLight.statusCancelledBg;
    final doneColor = isDark ? AppColorsDark.statusDone : AppColorsLight.statusDone;
    final doneBg = isDark ? AppColorsDark.statusDoneBg : AppColorsLight.statusDoneBg;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: warningColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(Icons.percent_rounded, color: warningColor, size: 20),
              title: const Text('Biaya Transaksi Midtrans',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Atur siapa yang menanggung biaya transaksi dan besaran tarifnya.',
                  style: TextStyle(fontSize: 11)),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocConsumer<MidtransFeeCubit, MidtransFeeState>(
                listener: (context, state) {
                  if (state is MidtransFeeSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(Icons.check_circle, color: doneColor, size: 18),
                        const SizedBox(width: 10),
                        Text('Pengaturan biaya Midtrans disimpan', style: TextStyle(color: doneColor)),
                      ]),
                      backgroundColor: doneBg,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ));
                  } else if (state is MidtransFeeError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(children: [
                        Icon(Icons.error_outline, color: cancelColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Gagal: ${state.message}', style: TextStyle(color: cancelColor))),
                      ]),
                      backgroundColor: cancelBg,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is MidtransFeeInitial || state is MidtransFeeLoading) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                  }
                  if (state is MidtransFeeError) {
                    return Text('Gagal memuat: ${state.message}', style: TextStyle(color: cancelColor));
                  }

                  final config = state is MidtransFeeLoaded ? state.config
                               : state is MidtransFeeSaving ? state.config
                               : state is MidtransFeeSaved  ? state.config
                               : null;
                  if (config == null) return const SizedBox.shrink();

                  return _MidtransFeeSettingBody(
                    isDark: isDark,
                    config: config,
                    isSaving: state is MidtransFeeSaving,
                    cubit: context.read<MidtransFeeCubit>(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Midtrans Fee Setting Body ─────────────────────────────────────────────────

class _MidtransFeeSettingBody extends StatefulWidget {
  final bool isDark;
  final MidtransFeeConfigEntity config;
  final bool isSaving;
  final MidtransFeeCubit cubit;

  const _MidtransFeeSettingBody({
    required this.isDark,
    required this.config,
    required this.isSaving,
    required this.cubit,
  });

  @override
  State<_MidtransFeeSettingBody> createState() => _MidtransFeeSettingBodyState();
}

class _MidtransFeeSettingBodyState extends State<_MidtransFeeSettingBody> {
  late Map<String, TextEditingController> _controllers;
  final TextEditingController _simulationCtrl = TextEditingController(text: '100000');

  @override
  void initState() {
    super.initState();
    _controllers = _buildControllers(widget.config);
    _simulationCtrl.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_MidtransFeeSettingBody old) {
    super.didUpdateWidget(old);
    final oldKeys = old.config.fees.map((f) => f.key).join(',');
    final newKeys = widget.config.fees.map((f) => f.key).join(',');
    if (oldKeys != newKeys) {
      _disposeControllers();
      _controllers = _buildControllers(widget.config);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    _simulationCtrl.dispose();
    super.dispose();
  }

  Map<String, TextEditingController> _buildControllers(MidtransFeeConfigEntity config) => {
        for (final fee in config.fees)
          fee.key: TextEditingController(
            text: fee.type == 'flat'
                ? (fee.amount?.toStringAsFixed(0) ?? '0')
                : (fee.rate?.toString() ?? '0'),
          ),
      };

  void _disposeControllers() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
  }

  MidtransFeeConfigEntity _buildUpdatedConfig(String bearer) {
    final newFees = widget.config.fees.map((fee) {
      final raw = double.tryParse(_controllers[fee.key]?.text ?? '') ?? 0;
      return MidtransFeeItemEntity(
        key: fee.key,
        label: fee.label,
        type: fee.type,
        amount: fee.type == 'flat' ? raw : null,
        rate: fee.type == 'percent' ? raw : null,
      );
    }).toList();
    return MidtransFeeConfigEntity(bearer: bearer, fees: newFees);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final config = widget.config;
    final isSaving = widget.isSaving;
    final cubit = widget.cubit;

    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
    final textHint = isDark ? AppColorsDark.textHint : AppColorsLight.textHint;
    final primaryColor = isDark ? AppColorsDark.primary : AppColorsLight.primary;
    final warningColor = isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final warningBg = isDark ? AppColorsDark.statusWaitingBg : AppColorsLight.statusWaitingBg;

    final isCustomer = config.isCustomerBearer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Biaya ditanggung oleh',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          _BearerOption(
            isDark: isDark,
            label: 'Wisma (Merchant)',
            description: 'Biaya dipotong dari penerimaan wisma. Penghuni bayar sesuai tagihan.',
            icon: Icons.store_outlined,
            selected: !isCustomer,
            accentColor: primaryColor,
            onTap: isSaving ? null : () => cubit.save(_buildUpdatedConfig('merchant')),
          ),
          const SizedBox(width: 8),
          _BearerOption(
            isDark: isDark,
            label: 'Penghuni',
            description: 'Biaya ditambahkan ke tagihan penghuni saat checkout.',
            icon: Icons.person_outline,
            selected: isCustomer,
            accentColor: warningColor,
            onTap: isSaving ? null : () => cubit.save(_buildUpdatedConfig('customer')),
          ),
        ]),

        if (isCustomer) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: warningColor.withOpacity(0.4)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 14, color: warningColor),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Biaya akan ditambahkan ke tagihan penghuni saat memilih metode pembayaran online.',
                style: TextStyle(fontSize: 11, color: warningColor, height: 1.4),
              )),
            ]),
          ),
        ],

        const SizedBox(height: 16),
        Text('Tarif Biaya per Metode',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, size: 13,
                  color: isDark ? AppColorsDark.primary : AppColorsLight.primary),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 11, color: textSecondary, height: 1.4),
                    children: [
                      const TextSpan(text: 'Tarif di bawah sesuai ketentuan resmi Midtrans. '),
                      TextSpan(
                        text: 'Jangan ubah kecuali ada pembaruan tarif dari Midtrans.',
                        style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: config.fees.asMap().entries.map((entry) {
              final index = entry.key;
              final fee = entry.value;
              final ctrl = _controllers[fee.key]!;
              final isLast = index == config.fees.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fee.label,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
                            Text(fee.type == 'flat' ? 'Flat per transaksi' : 'Persentase dari nominal',
                                style: TextStyle(fontSize: 10, color: textHint)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: ctrl,
                          enabled: !isSaving,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            suffixText: fee.type == 'flat' ? 'Rp' : '%',
                            suffixStyle: TextStyle(fontSize: 11, color: textHint),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: borderColor),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  if (!isLast) Divider(height: 1, color: borderColor),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : () => cubit.save(_buildUpdatedConfig(config.bearer)),
            icon: isSaving
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined, size: 16),
            label: Text(isSaving ? 'Menyimpan...' : 'Simpan Tarif', style: const TextStyle(fontSize: 13)),
          ),
        ),

        const SizedBox(height: 16),
        Divider(color: borderColor),
        const SizedBox(height: 12),
        Row(children: [
          Icon(Icons.calculate_outlined, size: 14, color: textSecondary),
          const SizedBox(width: 6),
          Text('Simulasi Biaya',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary)),
        ]),
        const SizedBox(height: 6),
        Text(
          'Masukkan nominal untuk melihat perkiraan biaya yang ditanggung dan uang yang diterima.',
          style: TextStyle(fontSize: 11, color: textHint, height: 1.4),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _simulationCtrl,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
          decoration: InputDecoration(
            labelText: 'Nominal Pembayaran',
            labelStyle: TextStyle(fontSize: 12, color: textSecondary),
            prefixText: 'Rp ',
            prefixStyle: TextStyle(fontSize: 13, color: textSecondary),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSimulationTable(config, isCustomer, textPrimary, textSecondary, textHint, borderColor, surfaceVariant, primaryColor, warningColor, isDark),
      ],
    );
  }

  Widget _buildSimulationTable(
    MidtransFeeConfigEntity config,
    bool isCustomer,
    Color textPrimary,
    Color textSecondary,
    Color textHint,
    Color borderColor,
    Color surfaceVariant,
    Color primaryColor,
    Color warningColor,
    bool isDark,
  ) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final nominal = double.tryParse(_simulationCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;

    if (nominal <= 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text('Masukkan nominal di atas untuk melihat simulasi.',
              style: TextStyle(fontSize: 11, color: textHint)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight).withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(children: [
              Expanded(flex: 3, child: Text('Metode',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textSecondary))),
              Expanded(flex: 3, child: Text('Biaya',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: textSecondary))),
              Expanded(flex: 4, child: Text('Dibayar Penghuni',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                      color: isCustomer ? warningColor : textSecondary))),
              Expanded(flex: 4, child: Text('Diterima Wisma',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryColor))),
            ]),
          ),
          ...config.fees.asMap().entries.map((entry) {
            final index = entry.key;
            final fee = entry.value;
            final isLast = index == config.fees.length - 1;
            final rawVal = double.tryParse(_controllers[fee.key]?.text ?? '') ?? 0;
            final feeAmt = fee.type == 'flat' ? rawVal : (nominal * rawVal / 100).roundToDouble();
            final customerPays = isCustomer ? nominal + feeAmt : nominal;
            final adminReceives = isCustomer ? nominal : nominal - feeAmt;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(fee.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textPrimary))),
                    Expanded(flex: 3, child: Text(fmt.format(feeAmt),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: textHint))),
                    Expanded(flex: 4, child: Text(fmt.format(customerPays),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: isCustomer ? warningColor : textPrimary))),
                    Expanded(flex: 4, child: Text(fmt.format(adminReceives),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: primaryColor))),
                  ]),
                ),
                if (!isLast) Divider(height: 1, color: borderColor),
              ],
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight).withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 10, color: textHint),
              const SizedBox(width: 4),
              Expanded(child: Text(
                isCustomer
                    ? 'Bearer: Penghuni — biaya ditambahkan ke tagihan. Wisma menerima penuh ${fmt.format(nominal)}.'
                    : 'Bearer: Wisma — penghuni bayar ${fmt.format(nominal)}, selisih biaya ditanggung wisma.',
                style: TextStyle(fontSize: 9, color: textHint, height: 1.3),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Bearer Option ─────────────────────────────────────────────────────────────

class _BearerOption extends StatelessWidget {
  final bool isDark;
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback? onTap;

  const _BearerOption({
    required this.isDark,
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceVariant = isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
    final borderColor = isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
    final textPrimary = isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? accentColor.withOpacity(0.08) : surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? accentColor.withOpacity(0.5) : borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 14, color: selected ? accentColor : textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? accentColor : textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected) Icon(Icons.check_circle, size: 12, color: accentColor),
              ]),
              const SizedBox(height: 3),
              Text(description,
                style: TextStyle(fontSize: 10, color: textSecondary, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
