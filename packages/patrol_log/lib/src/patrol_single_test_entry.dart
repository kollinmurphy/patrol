import 'package:patrol_log/patrol_log.dart';

/// Represents a single test entry.
///
/// A single test entry is a collection of entries that belong to the same test.
/// It starts with a [TestEntry] with status [TestEntryStatus.start] or
/// [TestEntryStatus.skip].
/// Entry with skip status contains only one entry.
/// Entry with start status contains also [StepEntry] and [LogEntry] entries.
/// The last entry in the collection is a test entry with status
/// [TestEntryStatus.success] or [TestEntryStatus.failure].
class PatrolSingleTestEntry {
  PatrolSingleTestEntry(this.openingTestEntry);

  final TestEntry openingTestEntry;
  TestEntry? closingTestEntry;

  /// List contains StepEntry and LogEntry entries.
  final List<Entry> _entries = [];

  void addEntry(Entry entry) {
    _entries.add(entry);
  }

  void closeTest(TestEntry testEntry) {
    closingTestEntry = testEntry;
  }

  /// The name of the test.
  String get name => openingTestEntry.name;

  /// The status of the test.
  TestEntryStatus get status =>
      closingTestEntry?.status ?? openingTestEntry.status;

  /// The name of the test with the path.
  ///
  /// If test is not closed yet, the path is unknown, so return only test name.
  String get nameWithPath => closingTestEntry?.nameWithPath ?? name;

  /// Step entries recorded for this test.
  Iterable<StepEntry> get _steps => _entries.whereType<StepEntry>();

  /// The number of steps that were started.
  int get stepsTotal =>
      _steps.where((e) => e.status == StepEntryStatus.start).length;

  /// The number of steps that completed successfully.
  int get stepsPassed =>
      _steps.where((e) => e.status == StepEntryStatus.success).length;

  /// The number of steps that failed.
  int get stepsFailed =>
      _steps.where((e) => e.status == StepEntryStatus.failure).length;

  /// The execution time of the test, or `null` if the test is not closed.
  Duration? get executionTimeOrNull =>
      closingTestEntry == null ? null : executionTime;

  /// The execution time of the test.
  Duration get executionTime {
    final testEntry = closingTestEntry;
    if (testEntry == null) {
      throw StateError('The test is not closed yet.');
    }
    return testEntry.executionTime(openingTestEntry.timestamp);
  }
}
