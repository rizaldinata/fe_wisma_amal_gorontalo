import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/presentation/bloc/reservation_detail_form/reservation_detail_form_bloc.dart';
import 'package:frontend/presentation/widget/core/appbar/app_topbar.dart';
import 'package:frontend/presentation/widget/core/card/app_section_card.dart';
import 'package:frontend/presentation/widget/core/card/selection_card.dart';
import 'package:frontend/presentation/widget/core/textform/textform.dart';
import 'package:frontend/presentation/widget/core/botton/button.dart';
import 'package:frontend/presentation/widget/core/wrapper/hover_wrapper.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/widget/core/snackbar/app_snackbar.dart';

import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/entity/setting/midtrans_method_entity.dart';
import 'package:frontend/domain/usecase/finance/get_available_payment_methods_usecase.dart';
import 'package:frontend/domain/usecase/resident/get_resident_profile_usecase.dart';
import 'package:frontend/domain/usecase/setting/get_public_settings_usecase.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';

@RoutePage()
class ReservationDetailFormPage extends StatelessWidget {
  final RoomEntity room;
  const ReservationDetailFormPage({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReservationDetailFormBloc(
            getSettingsUseCase: serviceLocator.get<GetPublicSettingsUseCase>(),
            createReservationUseCase: serviceLocator.get(),
            getProfileUseCase: serviceLocator.get<GetResidentProfileUseCase>(),
            getAvailablePaymentMethodsUseCase: serviceLocator
                .get<GetAvailablePaymentMethodsUseCase>(),
          )..add(
            InitReservationEvent(
              room,
              isLoggedIn: context.read<AuthBloc>().state.isLoggedIn,
              userId: context.read<AuthBloc>().state.userInfo?.id,
              userName: context.read<AuthBloc>().state.userInfo?.name,
            ),
          ),
      child: const ReservationDetailFormView(),
    );
  }
}

class ReservationDetailFormView extends StatefulWidget {
  const ReservationDetailFormView({super.key});

  @override
  State<ReservationDetailFormView> createState() =>
      _ReservationDetailFormViewState();
}

class _ReservationDetailFormViewState extends State<ReservationDetailFormView> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      initialDate: now,
    );

    if (date != null) {
      final formatted = '${date.day}/${date.month}/${date.year}';
      controller.text = formatted;
      onDateSelected(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationDetailFormBloc, ReservationDetailFormState>(
      listener: (context, state) {
        if (state.startDate != null) {
          final date = state.startDate!;
          _startDateController.text = '${date.day}/${date.month}/${date.year}';
        }
        if (state.endDate != null) {
          final date = state.endDate!;
          _endDateController.text = '${date.day}/${date.month}/${date.year}';
        }

        if (state.readyToConfirm) {
          context.read<ReservationDetailFormBloc>().add(
            const ResetConfirmFlagEvent(),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) _showConfirmReservationDialog(context);
          });
        }

        if (state.status == FormzSubmissionStatus.success) {
          AppSnackbar.showSuccess(
            'Pemesanan berhasil dibuat. Silakan selesaikan pembayaran.',
          );
          if (state.paymentMethod == 'tunai') {
            context.router.replace(
              PaymentUploadRoute(reservation: state.createdReservation!),
            );
          } else {
            context.router.replace(
              MidtransPaymentRoute(
                reservation: state.createdReservation!.copyWith(
                  selectedPaymentMethod: state.selectedMidtransMethod,
                ),
              ),
            );
          }
        } else if (state.status == FormzSubmissionStatus.failure) {
          final error = state.errorMessage ?? 'Gagal membuat pemesanan';
          AppSnackbar.showError(error);

          if (error.toLowerCase().contains('profil') ||
              error.toLowerCase().contains('biodata')) {
            context.router.push(const CompleteProfileRoute());
          }
        }
      },
      builder: (context, state) {
        final room = state.room;
        final isDark = AppTheme.isDark(context);

        // ── Design system tokens ─────────────────────────────────────────────
        final textPrimary =
            isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
        final textSecondary =
            isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
        final primaryColor =
            isDark ? AppColorsDark.primary : AppColorsLight.primary;
        final borderColor =
            isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;

        final statusWaiting =
            isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
        final statusWaitingBg = isDark
            ? AppColorsDark.statusWaitingBg
            : AppColorsLight.statusWaitingBg;
        final statusWaitingBorder = isDark
            ? AppColorsDark.statusWaitingBorder
            : AppColorsLight.statusWaitingBorder;

        if (room == null) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColorsDark.background
                : AppColorsLight.background,
            body: Column(
              children: [
                AppTopBar(
                  title: 'Detail Reservasi',
                  breadcrumb: 'Reservasi / Detail',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.router.pop(),
                    tooltip: 'Kembali',
                  ),
                ),
                Expanded(child: _buildSkeleton(isDark)),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColorsDark.background
              : AppColorsLight.background,
          body: Column(
            children: [
              AppTopBar(
                title: 'Detail Reservasi',
                breadcrumb: 'Reservasi / Detail',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.router.pop(),
                  tooltip: 'Kembali',
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxxl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT ─────────────────────────────────────────────────
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              /// KAMAR YANG DIPILIH
                              AppSectionCard(
                                title: 'Kamar yang dipilih',
                                icon: Icons.bed_outlined,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColorsDark.primaryLight
                                        : AppColorsLight.primaryLight,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusLg,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColorsDark.primary.withValues(
                                              alpha: 0.4,
                                            )
                                          : AppColorsLight.primary.withValues(
                                              alpha: 0.3,
                                            ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'No. ${room.number} • ${room.facilities.join(', ')}',
                                        style: TextStyle(color: textSecondary),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Bulanan: ${room.priceFormatted} | Tahunan: Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// JENIS SEWA
                              AppSectionCard(
                                title: 'Pilih Jenis Sewa',
                                icon: Icons.date_range_outlined,
                                child: Wrap(
                                  spacing: AppSpacing.lg,
                                  runSpacing: AppSpacing.lg,
                                  children: [
                                    SelectionCard.vertical(
                                      title: 'Sewa Bulanan',
                                      subtitle: 'Hemat jangka pendek',
                                      valueLabel:
                                          '${room.priceFormatted} / bulan',
                                      selected: state.rentType == 'Bulanan',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const RentTypeChanged('Bulanan'),
                                          ),
                                      minWidth: 260,
                                      maxWidth: 358,
                                    ),
                                    SelectionCard.vertical(
                                      title: 'Sewa Tahunan',
                                      subtitle:
                                          'Lebih hemat untuk jangka panjang',
                                      valueLabel:
                                          'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')} / tahun',
                                      selected: state.rentType == 'Tahunan',
                                      onTap: () => context
                                          .read<ReservationDetailFormBloc>()
                                          .add(
                                            const RentTypeChanged('Tahunan'),
                                          ),
                                      minWidth: 260,
                                      maxWidth: 358,
                                    ),
                                    // Daily logic (dipertahankan)
                                    if (state.isDailyRentalEnabled &&
                                        room.priceDaily > 0)
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// DETAIL SEWA
                              AppSectionCard(
                                title: 'Detail Sewa',
                                icon: Icons.calendar_month_outlined,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _pickDate(
                                              context,
                                              _startDateController,
                                              (date) {
                                                context
                                                    .read<
                                                      ReservationDetailFormBloc
                                                    >()
                                                    .add(
                                                      StartDateChanged(date),
                                                    );
                                              },
                                            ),
                                            child: AbsorbPointer(
                                              child: CustomTextForm(
                                                title: 'Tanggal Mulai',
                                                hintText: 'Pilih tanggal',
                                                controller:
                                                    _startDateController,
                                                isRequired: true,
                                                suffixIcon: const Icon(
                                                  Icons.calendar_today,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        if (state.rentType == 'Bulanan' ||
                                            state.rentType == 'Tahunan')
                                          Expanded(
                                            child: CustomTextForm(
                                              title: state.rentType == 'Bulanan'
                                                  ? 'Jumlah Bulan'
                                                  : 'Jumlah Tahun',
                                              hintText:
                                                  state.rentType == 'Bulanan'
                                                  ? 'Berapa bulan?'
                                                  : 'Berapa tahun?',
                                              keyboardType:
                                                  TextInputType.number,
                                              initialValue:
                                                  state.durationMonths
                                                      .toString(),
                                              onChanged: (val) {
                                                final value =
                                                    int.tryParse(val) ?? 1;
                                                context
                                                    .read<
                                                      ReservationDetailFormBloc
                                                    >()
                                                    .add(
                                                      DurationMonthsChanged(
                                                        value,
                                                      ),
                                                    );
                                              },
                                              isRequired: true,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (state.rentType == 'Bulanan' ||
                                        state.rentType == 'Tahunan') ...[
                                      const SizedBox(height: AppSpacing.lg),
                                      CustomTextForm(
                                        title: 'Estimasi Tanggal Selesai',
                                        hintText: '-',
                                        controller: _endDateController,
                                        enabled: false,
                                        isRequired: false,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.xxl),

                              /// SKEMA PEMBAYARAN — hanya muncul jika start_date > H+7
                              if (state.isDpAvailable) ...[
                                AppSectionCard(
                                  title: 'Skema Pembayaran',
                                  icon: Icons.account_balance_outlined,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tanggal mulai lebih dari 7 hari ke depan. Anda bisa memilih membayar DP (uang muka 50%) sekarang dan melunasi sisa sebelum tanggal masuk.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Wrap(
                                        spacing: AppSpacing.lg,
                                        runSpacing: AppSpacing.lg,
                                        children: [
                                          SelectionCard.vertical(
                                            title: 'Bayar Penuh',
                                            subtitle:
                                                'Lunasi semua biaya sekarang',
                                            valueLabel:
                                                'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
                                            selected:
                                                state.paymentScheme == 'full',
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentSchemeChanged(
                                                    'full',
                                                  ),
                                                ),
                                            minWidth: 220,
                                            maxWidth: 320,
                                          ),
                                          SelectionCard.vertical(
                                            title: 'DP (Uang Muka)',
                                            subtitle:
                                                'Bayar 50% sekarang, lunasi sebelum tanggal masuk',
                                            valueLabel:
                                                'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                            selected:
                                                state.paymentScheme == 'dp',
                                            accentColor: statusWaiting,
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentSchemeChanged(
                                                    'dp',
                                                  ),
                                                ),
                                            minWidth: 220,
                                            maxWidth: 320,
                                          ),
                                        ],
                                      ),
                                      if (state.paymentScheme == 'dp') ...[
                                        const SizedBox(height: AppSpacing.md),
                                        // ── Banner DP (design system tokens) ──
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusWaitingBg,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: statusWaitingBorder,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: statusWaiting,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.sm,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'DP harus dibayar dalam 15 menit setelah pemesanan. Sisa pembayaran wajib dilunasi sebelum tanggal masuk.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: statusWaiting,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxl),
                              ],

                              /// METODE PEMBAYARAN
                              AppSectionCard(
                                title: 'Metode Pembayaran',
                                icon: Icons.payment_outlined,
                                child: Column(
                                  children: [
                                    Wrap(
                                      spacing: AppSpacing.lg,
                                      runSpacing: AppSpacing.lg,
                                      children: [
                                        if (state.isMidtransEnabled)
                                          SelectionCard.horizontal(
                                            title: 'Pembayaran Online',
                                            subtitle: _midtransSubtitle(
                                              state.midtransPaymentMethods,
                                            ),
                                            icon: Icons.account_balance_wallet,
                                            selected:
                                                state.paymentMethod == 'online',
                                            onTap: () => context
                                                .read<
                                                  ReservationDetailFormBloc
                                                >()
                                                .add(
                                                  const PaymentMethodChanged(
                                                    'online',
                                                  ),
                                                ),
                                            minWidth: 260,
                                            maxWidth: 358,
                                          ),
                                        SelectionCard.horizontal(
                                          title: 'Pembayaran Manual',
                                          subtitle:
                                              'Transfer atau Cash dengan Bukti',
                                          icon: Icons.payments,
                                          selected:
                                              state.paymentMethod == 'tunai',
                                          onTap: () => context
                                              .read<ReservationDetailFormBloc>()
                                              .add(
                                                const PaymentMethodChanged(
                                                  'tunai',
                                                ),
                                              ),
                                          minWidth: 260,
                                          maxWidth: 358,
                                        ),
                                      ],
                                    ),

                                    if (state.paymentMethod == 'online') ...[
                                      const SizedBox(height: AppSpacing.xxl),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Pilih Metode Pembayaran',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Metode yang Anda pilih akan dibuka di halaman pembayaran Midtrans.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),

                                      // ── Semua metode maintenance ──────────
                                      if (state.midtransPaymentMethods
                                              .isNotEmpty &&
                                          state.midtransPaymentMethods.every(
                                            (m) => !m.available,
                                          )) ...[
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusWaitingBg,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: statusWaitingBorder,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.build_outlined,
                                                color: statusWaiting,
                                                size: 20,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Semua metode pembayaran online sedang maintenance',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: statusWaiting,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.xs,
                                                    ),
                                                    Text(
                                                      'Tidak ada metode yang tersedia saat ini. Silakan gunakan Pembayaran Manual atau coba lagi nanti.',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: statusWaiting,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: AppSpacing.sm,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () => context
                                                          .read<
                                                            ReservationDetailFormBloc
                                                          >()
                                                          .add(
                                                            const PaymentMethodChanged(
                                                              'tunai',
                                                            ),
                                                          ),
                                                      child: Text(
                                                        'Beralih ke Pembayaran Manual →',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: statusWaiting,
                                                          decoration: TextDecoration
                                                              .underline,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                      ],

                                      // ── Tidak ada metode ──────────────────
                                      if (state
                                          .midtransPaymentMethods.isEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.lg,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColorsDark.surface
                                                : AppColorsLight.surface,
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusMd,
                                            ),
                                            border: Border.all(
                                              color: borderColor,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: textSecondary,
                                                size: 18,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.md,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Tidak ada metode pembayaran online yang aktif. Hubungi pengelola atau gunakan Pembayaran Manual.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: textSecondary,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                mainAxisSpacing:
                                                    AppSpacing.sm,
                                                crossAxisSpacing: AppSpacing.sm,
                                                mainAxisExtent: 72,
                                              ),
                                          itemCount: state
                                              .midtransPaymentMethods.length,
                                          itemBuilder: (context, index) {
                                            final method = state
                                                .midtransPaymentMethods[index];
                                            final isSelected =
                                                state.selectedMidtransMethod ==
                                                method.code;
                                            return _midtransMethodCard(
                                              method: method,
                                              selected: isSelected,
                                              onTap: method.available
                                                  ? () => context
                                                        .read<
                                                          ReservationDetailFormBloc
                                                        >()
                                                        .add(
                                                          SelectedMidtransMethodChanged(
                                                            isSelected
                                                                ? null
                                                                : method.code,
                                                          ),
                                                        )
                                                  : () {},
                                            );
                                          },
                                        ),
                                    ] else if (state.paymentMethod ==
                                        'tunai') ...[
                                      const SizedBox(height: AppSpacing.lg),
                                      // ── Banner Pembayaran Manual ────────────
                                      Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.lg,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusWaitingBg,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusMd,
                                          ),
                                          border: Border.all(
                                            color: statusWaitingBorder,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: statusWaiting,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.md,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Pembayaran Manual',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color: statusWaiting,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: AppSpacing.xs,
                                                  ),
                                                  Text(
                                                    'Lakukan transfer bank atau bayar cash, lalu unggah bukti pembayaran di langkah berikutnya.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: statusWaiting,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideY(
                                begin: 0.05,
                                end: 0,
                                duration: 300.ms,
                              ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.xxl),

                      /// RIGHT ────────────────────────────────────────────────
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // ── Ringkasan Biaya ─────────────────────────────
                            AppSectionCard(
                              title: 'Ringkasan Biaya',
                              icon: Icons.receipt_long_outlined,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Baris nama kamar + durasi
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        room.title,
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                      Text(
                                        '${state.duration} '
                                        '${state.rentType == 'Bulanan' ? 'Bulan' : state.rentType == 'Tahunan' ? 'Tahun' : 'Hari'}',
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Baris harga per periode
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Harga / '
                                        '${state.rentType == 'Bulanan' ? 'bulan' : state.rentType == 'Tahunan' ? 'tahun' : 'hari'}',
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                      Text(
                                        state.rentType == 'Bulanan'
                                            ? room.priceFormatted
                                            : state.rentType == 'Tahunan'
                                            ? 'Rp ${NumberFormat.decimalPattern('id').format((room.price * 12).toInt()).replaceAll(',', '.')}'
                                            : room.priceDailyFormatted,
                                        style:
                                            TextStyle(color: textSecondary),
                                      ),
                                    ],
                                  ),

                                  // ── Divider borderLight ──────────────────
                                  const SizedBox(height: AppSpacing.sm),
                                  Container(
                                    height: 1,
                                    color: borderColor,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Baris Total Biaya
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Biaya',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (state.paymentScheme == 'dp') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(height: 1, color: borderColor),
                                    const SizedBox(height: AppSpacing.xs),

                                    // Baris DP sekarang
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Bayar Sekarang (DP)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            color: statusWaiting,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),

                                    // Baris pelunasan
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Pelunasan (sebelum tanggal masuk)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.xl),

                            // ── Tombol Pesan Kamar ──────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: BasicButton(
                                label: 'Pesan Kamar',
                                isLoading: state.status ==
                                    FormzSubmissionStatus.inProgress,
                                onPressed: () {
                                  _showConfirmReservationDialog(context);
                                },
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // ── Catatan bawah ────────────────────────────────
                            Text(
                              'Setelah submit, Anda akan diarahkan untuk melakukan pembayaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms)
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              duration: 300.ms,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(
                    bottom: i < 2 ? AppSpacing.xxl : 0,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      height: i == 0 ? 120 : 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(
            flex: 1,
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmReservationDialog(BuildContext context) {
    final state = context.read<ReservationDetailFormBloc>().state;
    final authState = context.read<AuthBloc>().state;

    // 1. Pengecekan Login
    if (!authState.isLoggedIn) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Diperlukan'),
          content: const Text(
            'Untuk memesan kamar, Anda perlu login atau membuat akun terlebih dahulu.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Nanti Saja'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.router.push(LoginRoute(pendingRoom: state.room));
              },
              child: const Text('Login Sekarang'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Pengecekan Tanggal Mulai
    if (state.startDate == null) {
      AppSnackbar.showError('Pilih tanggal mulai terlebih dahulu');
      return;
    }

    // 3. Pengecekan ketersediaan metode Midtrans
    if (state.paymentMethod == 'online') {
      final methods = state.midtransPaymentMethods;
      if (methods.isEmpty || methods.every((m) => !m.available)) {
        AppSnackbar.showError(
          methods.isEmpty
              ? 'Tidak ada metode pembayaran online yang aktif. Gunakan Pembayaran Manual.'
              : 'Semua metode pembayaran online sedang maintenance. Gunakan Pembayaran Manual.',
        );
        return;
      }
    }

    // 4. Pengecekan Profil
    if (!state.isProfileComplete) {
      AppSnackbar.showInfo(
        'Silakan lengkapi biodata Anda (NIK, nomor telepon, dan alamat KTP) sebelum melanjutkan pemesanan.',
      );
      context.router.push(const CompleteProfileRoute()).then((_) {
        if (context.mounted) {
          context.read<ReservationDetailFormBloc>().add(
            const RefreshProfileStatusEvent(thenConfirm: true),
          );
        }
      });
      return;
    }

    final isDark = AppTheme.isDark(context);
    final statusWaiting =
        isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
    final statusWaitingBg = isDark
        ? AppColorsDark.statusWaitingBg
        : AppColorsLight.statusWaitingBg;
    final statusWaitingBorder = isDark
        ? AppColorsDark.statusWaitingBorder
        : AppColorsLight.statusWaitingBorder;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin melakukan pemesanan kamar ini?',
            ),
            const SizedBox(height: AppSpacing.lg),
            _infoRow('Kamar', state.room?.title ?? '-'),
            _infoRow(
              'Mulai',
              DateFormat('dd/MM/yyyy').format(state.startDate!),
            ),
            _infoRow(
              'Total',
              'Rp ${NumberFormat.decimalPattern('id').format(state.totalPrice).replaceAll(',', '.')}',
            ),
            if (state.paymentScheme == 'dp') ...[
              _infoRow('Skema', 'DP (Uang Muka 50%)'),
              _infoRow(
                'Bayar Sekarang',
                'Rp ${NumberFormat.decimalPattern('id').format(state.dpAmount.toInt()).replaceAll(',', '.')}',
              ),
            ] else
              _infoRow('Skema', 'Bayar Penuh'),
            _infoRow(
              'Metode',
              state.paymentMethod == 'online'
                  ? (state.selectedMidtransMethod != null
                        ? 'Online · ${_kMidtransMethodMap[state.selectedMidtransMethod]?.name ?? state.selectedMidtransMethod!.toUpperCase()}'
                        : 'Online (Midtrans)')
                  : 'Manual',
            ),
            if (state.paymentScheme == 'dp') ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusWaitingBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: statusWaitingBorder),
                ),
                child: Text(
                  'DP harus dibayar dalam 15 menit. Sisa pembayaran wajib dilunasi sebelum tanggal masuk.',
                  style: TextStyle(
                    fontSize: 11,
                    color: statusWaiting,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ReservationDetailFormBloc>().add(
                const SubmitReservation(),
              );
            },
            child: Text(
              state.paymentScheme == 'dp'
                  ? 'Ya, Bayar DP Sekarang'
                  : 'Ya, Pesan Sekarang',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Midtrans payment method metadata ─────────────────────────────────────────

class _MidtransMethodInfo {
  const _MidtransMethodInfo(this.name, this.desc, this.icon);
  final String name;
  final String desc;
  final IconData icon;
}

const Map<String, _MidtransMethodInfo> _kMidtransMethodMap = {
  'qris': _MidtransMethodInfo(
    'QRIS',
    'Scan QR dari semua e-wallet & bank',
    Icons.qr_code,
  ),
  'gopay': _MidtransMethodInfo(
    'GoPay',
    'Bayar dengan saldo GoPay',
    Icons.account_balance_wallet,
  ),
  'shopeepay': _MidtransMethodInfo(
    'ShopeePay',
    'Bayar dengan saldo ShopeePay',
    Icons.shopping_bag,
  ),
  'dana': _MidtransMethodInfo(
    'DANA',
    'Bayar dengan saldo DANA',
    Icons.account_balance_wallet,
  ),
  'linkaja': _MidtransMethodInfo(
    'LinkAja',
    'Bayar dengan LinkAja',
    Icons.account_balance_wallet,
  ),
  'ovo': _MidtransMethodInfo(
    'OVO',
    'Bayar dengan saldo OVO',
    Icons.account_balance_wallet,
  ),
  'bca_va': _MidtransMethodInfo(
    'BCA Virtual Account',
    'Transfer via ATM / m-BCA',
    Icons.account_balance,
  ),
  'bni_va': _MidtransMethodInfo(
    'BNI Virtual Account',
    'Transfer via ATM / BNI Mobile',
    Icons.account_balance,
  ),
  'bri_va': _MidtransMethodInfo(
    'BRI Virtual Account',
    'Transfer via ATM / BRImo',
    Icons.account_balance,
  ),
  'mandiri_va': _MidtransMethodInfo(
    'Mandiri Virtual Account',
    'Transfer via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'echannel': _MidtransMethodInfo(
    'Mandiri Bill',
    'Bayar via Mandiri Livin\'',
    Icons.account_balance,
  ),
  'permata_va': _MidtransMethodInfo(
    'Permata Virtual Account',
    'Transfer via ATM Permata',
    Icons.account_balance,
  ),
  'other_va': _MidtransMethodInfo(
    'Virtual Account',
    'Transfer via bank lain',
    Icons.account_balance,
  ),
  'alfamart': _MidtransMethodInfo(
    'Alfamart',
    'Bayar di kasir Alfamart',
    Icons.store,
  ),
  'indomaret': _MidtransMethodInfo(
    'Indomaret',
    'Bayar di kasir Indomaret',
    Icons.store,
  ),
  'credit_card': _MidtransMethodInfo(
    'Kartu Kredit/Debit',
    'Visa, Mastercard, JCB',
    Icons.credit_card,
  ),
  'akulaku': _MidtransMethodInfo(
    'Akulaku',
    'Cicilan 0% via Akulaku',
    Icons.credit_card,
  ),
  'kredivo': _MidtransMethodInfo(
    'Kredivo',
    'Cicilan via Kredivo',
    Icons.credit_card,
  ),
};

/// Subtitle dinamis berdasarkan metode yang tersedia
String _midtransSubtitle(List<MidtransMethodEntity> methods) {
  if (methods.isEmpty) return 'Tidak ada metode aktif';
  final available = methods.where((m) => !m.maintenance).toList();
  if (available.isEmpty) return 'Semua metode sedang maintenance';
  final names = available
      .map(
        (m) => m.label.isNotEmpty
            ? m.label
            : (_kMidtransMethodMap[m.code]?.name ?? m.code.toUpperCase()),
      )
      .take(3)
      .join(', ');
  return available.length > 3
      ? '$names, +${available.length - 3} lainnya'
      : names;
}

/// Kartu metode pembayaran Midtrans — list-tile style, tinggi tetap 72px
Widget _midtransMethodCard({
  required MidtransMethodEntity method,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Builder(
    builder: (context) {
      final isDark = AppTheme.isDark(context);
      final info =
          _kMidtransMethodMap[method.code] ??
          _MidtransMethodInfo(
            method.code.toUpperCase(),
            'Metode Midtrans',
            Icons.payment,
          );
      final displayName = method.label.isNotEmpty ? method.label : info.name;
      final isMaintenance = method.maintenance;
      final isUnavailable = !method.available;

      // ── Design system tokens ───────────────────────────────────────────────
      final primaryColor =
          isDark ? AppColorsDark.primary : AppColorsLight.primary;
      final primaryLight =
          isDark ? AppColorsDark.surfaceVariant : AppColorsLight.primaryLight;
      final surfaceColor =
          isDark ? AppColorsDark.surface : AppColorsLight.surface;
      final borderColor =
          isDark ? AppColorsDark.borderLight : AppColorsLight.borderLight;
      final textPrimary =
          isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;
      final textSecondary =
          isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;
      final statusWaiting =
          isDark ? AppColorsDark.statusWaiting : AppColorsLight.statusWaiting;
      final iconBg =
          isDark ? AppColorsDark.surfaceVariant : AppColorsLight.surfaceVariant;
      final iconBgSelected =
          isDark
          ? AppColorsDark.primary.withValues(alpha: 0.2)
          : AppColorsLight.primary.withValues(alpha: 0.12);

      return Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: HoverTapWrapper(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          hoverColor: isUnavailable
              ? Colors.transparent
              : primaryColor.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected ? primaryLight : surfaceColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: selected ? primaryColor : borderColor,
                width: selected ? 1.5 : 1.0,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? iconBgSelected : iconBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      info.icon,
                      size: 20,
                      color: selected ? primaryColor : textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Nama + deskripsi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            height: 1.3,
                            color: selected ? primaryColor : textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        if (isMaintenance)
                          Text(
                            'Sedang Maintenance',
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              color: statusWaiting,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            info.desc,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              color: textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isMaintenance)
                    Icon(
                      Icons.build_outlined,
                      size: 16,
                      color: statusWaiting,
                    )
                  else
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: selected ? primaryColor : borderColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
