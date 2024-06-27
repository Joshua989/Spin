import 'package:json_annotation/json_annotation.dart';
import 'package:spin/bloc/spin_cubit/spin_state.dart';

part 'exported_report.g.dart';

@JsonSerializable()
class ExportedReport {
  final SpinState report;
  final String name;

  const ExportedReport({
    required this.report,
    required this.name,
  });

  factory ExportedReport.fromJson(Map<String, dynamic> json) =>
      _$ExportedReportFromJson(json);
  Map<String, dynamic> toJson() => _$ExportedReportToJson(this);
}