import 'package:flutter/material.dart';
import 'package:flowboard/core/di/injection.dart';
import 'package:flowboard/core/session/user_role.dart';
import 'package:flowboard/features/attendance/domain/entity/attendance_record.dart';
import 'package:flowboard/features/attendance/domain/repository/attendance_repository.dart';
import 'package:flowboard/features/attendance/presentation/viewmodel/attendance_view_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, this.reportOnly = false});

  final bool reportOnly;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final AttendanceViewModel vm;
  final AttendanceRepository repository = getIt<AttendanceRepository>();
  
  int tab = 0;
  int? selectedArea, selectedEmployee;
  List> areas = [], employees = [];
  Map<String, dynamic>? summary;
  String? reportError;
  bool busy = false;

  bool get hr => vm.employeeProvider.currentRole() == UserRole.humanResources;

  @override
  void initState() {
    super.initState();
    vm = getIt<AttendanceViewModel>()..addListener(_refresh);
    if (widget.reportOnly) tab = 2;
    _init();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    await vm.load();
    if (hr) {
      try {
        final a = await repository.areas();
        if (mounted) setState(() => areas = a);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    vm.removeListener(_refresh);
    vm.dispose();
    super.dispose();
  }

  Future<void> _dates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: vm.from, end: vm.to),
    );
    if (range == null) return;
    await vm.setDates(
      range.start,
      range.end,
      employeeId: tab == 1 ? selectedEmployee : null,
      areaId: tab == 2 ? selectedArea : null,
    );
    if (tab == 2) await _report();
  }

  Future<void> _report() async {
    if (selectedArea == null) return;
    setState(() {
      busy = true;
      reportError = null;
    });
    try {
      final data = await repository.areaSummary(selectedArea!, vm.from, vm.to);
      await vm.load(areaId: selectedArea);
      if (mounted) setState(() => summary = data);
    } catch (e) {
      if (mounted) setState(() => reportError = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _employeeSearch() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Buscar colaborador'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre o código'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, controller.text),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (query == null) return;
    try {
      final result = await repository.employees(query);
      if (!mounted) return;
      setState(() => employees = result);
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron colaboradores')),
        );
      }
    } catch (e) {
      _message('$e');
    }
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }
  }

  Future<void> _punch(String type) async {
    setState(() => busy = true);
    try {
      await vm.punch(type);
      _message('Marcación registrada correctamente');
    } catch (e) {
      _message('No se pudo registrar: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _justify(AttendanceRecord r) async {
    if (r.id == null) {
      _message('Registro sin identificador');
      return;
    }
    final reason = TextEditingController();
    final url = TextEditingController();
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Justificar asistencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reason,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Motivo *'),
            ),
            TextField(
              controller: url,
              decoration: const InputDecoration(
                labelText: 'URL de evidencia (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (reason.text.trim().isEmpty) {
        _message('Ingresa un motivo');
      } else {
        try {
          await vm.justify(
            r.id!,
            reason.text.trim(),
            url.text.trim().isEmpty ? null : url.text.trim(),
          );
          _message('Justificación enviada');
        } catch (e) {
          _message('$e');
        }
      }
    }
    reason.dispose();
    url.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            widget.reportOnly ? 'Asistencia por área' : 'Asistencia',
          ),
          actions: [
            IconButton(
              tooltip: 'Actualizar',
              onPressed: () => tab == 2
                  ? _report()
                  : vm.load(employeeId: tab == 1 ? selectedEmployee : null),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (hr && !widget.reportOnly)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Mi asistencia')),
                      ButtonSegment(value: 1, label: Text('Personal')),
                      ButtonSegment(value: 2, label: Text('Áreas')),
                    ],
                    selected: {tab},
                    onSelectionChanged: (v) {
                      setState(() => tab = v.first);
                      if (tab == 0) vm.load();
                    },
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _header(),
                    const SizedBox(height: 12),
                    if (tab == 0) ..._my(),
                    if (tab == 1) ..._employees(),
                    if (tab == 2) ..._areas(),
                    if (vm.loading || busy)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (vm.error != null)
                      Text(
                        vm.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    if (!vm.loading && (tab != 2 || selectedArea != null)) ...[
                      _metrics(),
                      const SizedBox(height: 12),
                      Text(
                        'Registros',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (vm.records.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No hay registros para los filtros seleccionados.',
                            ),
                          ),
                        ),
                      ...vm.records.map(_record),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _header() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab == 0
                    ? 'Control de asistencia'
                    : tab == 1
                        ? 'Asistencia del personal'
                        : 'Reporte por área',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _dates,
                icon: const Icon(Icons.date_range),
                label: Text('${_date(vm.from)}  —  ${_date(vm.to)}'),
              ),
            ],
          ),
        ),
      );

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  List<Widget> _my() => [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marcación de jornada'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: busy ? null : () => _punch('CHECK_IN'),
                      icon: const Icon(Icons.login),
                      label: const Text('Marcar entrada'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : () => _punch('CHECK_OUT'),
                      icon: const Icon(Icons.logout),
                      label: const Text('Marcar salida'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ];

  List<Widget> _employees() => [
        OutlinedButton.icon(
          onPressed: _employeeSearch,
          icon: const Icon(Icons.search),
          label: const Text('Buscar colaborador'),
        ),
        if (employees.isNotEmpty)
          DropdownButtonFormField<int>(
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Colaborador'),
            items: employees
                .map(
                  (e) => DropdownMenuItem(
                    value: (e['id'] as num).toInt(),
                    child: Text(
                      '${e['fullName'] ?? ((e['firstName'] ?? '').toString() + ' ' + (e['lastName'] ?? '').toString())}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              selectedEmployee = id;
              if (id != null) vm.load(employeeId: id);
            },
          ),
        const SizedBox(height: 12),
      ];

  List<Widget> _areas() => [
        DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Área'),
          value: selectedArea,
          items: areas
              .map(
                (a) => DropdownMenuItem(
                  value: (a['id'] as num).toInt(),
                  child: Text('${a['name'] ?? a['areaName'] ?? 'Área'}'),
                ),
              )
              .toList(),
          onChanged: (id) {
            selectedArea = id;
            _report();
          },
        ),
        if (reportError != null) Text(reportError!),
        if (summary != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen del área',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...summary!.entries
                      .where((e) => e.value is num || e.value is String)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text('${e.key}: ${e.value}'),
                        ),
                      ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
      ];

  Widget _metrics() {
    final r = vm.records;
    final late = r.where((x) => x.status.toUpperCase() == 'LATE').length;
    final absent = r.where((x) => x.status.toUpperCase() == 'ABSENT').length;
    final hours =
        r.fold<double>(0, (sum, x) => sum + (x.effectiveHours ?? 0));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metric('Registros', '${r.length}', Icons.event_available),
        _metric('Tardanzas', '$late', Icons.schedule),
        _metric('Faltas', '$absent', Icons.event_busy),
        _metric('Horas', hours.toStringAsFixed(1), Icons.timelapse),
      ],
    );
  }

  Widget _metric(String label, String value, IconData icon) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 20),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(label),
            ],
          ),
        ),
      );

  Widget _record(AttendanceRecord r) => Card(
        child: ListTile(
          title: Text(
            '${r.employeeName?.isNotEmpty == true ? r.employeeName : 'Asistencia'} · ${r.workDate}',
          ),
          subtitle: Text(
            'Entrada: ${r.checkInTime ?? '—'}  ·  Salida: ${r.checkOutTime ?? '—'}\n${r.statusLabel} · ${r.effectiveHours?.toStringAsFixed(1) ?? '—'} h',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          isThreeLine: true,
          trailing: tab == 0 && r.id != null
              ? IconButton(
                  tooltip: 'Justificar',
                  icon: const Icon(Icons.edit_note),
                  onPressed: () => _justify(r),
                )
              : null,
        ),
      );
}