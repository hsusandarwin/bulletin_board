import 'package:bulletin_board/provider/loading/loading_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoadingOverlay extends StatefulHookConsumerWidget {
  const LoadingOverlay({super.key,required this.child, required bool isLoading});

final Widget child;

  @override
  ConsumerState<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends ConsumerState<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    return Stack(
      children: [
        widget.child,
        if(isLoading)
        const Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
        if(isLoading)
        Opacity(
          opacity: 0.8,
          child: ModalBarrier(dismissible: false,color: Colors.black,),
          )
      ],
    );
  }
}