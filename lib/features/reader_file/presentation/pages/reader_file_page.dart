import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../generated/l10n.dart';
import '../../../../injection_container.dart';
import '../bloc/reader_file_bloc.dart';

class ReaderFilePage extends StatelessWidget {
  final String id;
  const ReaderFilePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReaderFileBloc>()..add(FetchReaderFile(id)),
      child: Scaffold(
        appBar: AppBar(title: Text(S.of(context).readerFileTitle)),
        body: BlocBuilder<ReaderFileBloc, ReaderFileState>(
          builder: (context, state) {
            return switch (state) {
              ReaderFileLoading() =>
                const Center(child: CircularProgressIndicator()),
              ReaderFileLoaded(:final data) => Center(child: Text(data.id)),
              ReaderFileError(:final message) => Center(child: Text(message)),
              _ => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }
}
