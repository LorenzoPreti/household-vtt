import 'package:flutter/material.dart';

class SidebarRetrattile extends StatefulWidget {
  final Widget child;
  final Widget pannelloContent;

  const SidebarRetrattile({super.key, required this.child, required this.pannelloContent});

  @override
  State<SidebarRetrattile> createState() => _SidebarRetrattileState();
}

class _SidebarRetrattileState extends State<SidebarRetrattile> {
  bool _isPanelOpen = false;
  final double _panelWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final double paddingDestro = (_isPanelOpen && constraints.maxWidth > 900) ? _panelWidth : 0.0;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.only(right: paddingDestro),
            child: widget.child,
          );
        }),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          top: MediaQuery.of(context).size.height / 2 - 30,
          right: _isPanelOpen ? _panelWidth : 0,
          child: GestureDetector(
            onTap: () => setState(() => _isPanelOpen = !_isPanelOpen),
            child: Container(
              width: 30, height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.white10),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              ),
              child: Icon(_isPanelOpen ? Icons.chevron_right : Icons.chevron_left, color: Colors.white70, size: 20),
            ),
          ),
        ),

        // Sostituisci il blocco Positioned del pannello con questo:
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          top: 0,
          bottom: 0,
          // Se è chiuso, la posizione right è -300 (fuori schermo a destra)
          // Se è aperto, la posizione right è 0 (dentro schermo)
          right: _isPanelOpen ? 0 : -300,
          child: SizedBox(
            width: _panelWidth, // Larghezza fissa di 300
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.95),
                border: const Border(left: BorderSide(color: Colors.white10)),
              ),
              // Mettiamo il contenuto qui. Essendo fisso a 300,
              // il Wrap non si accorgerà mai della transizione!
              child: widget.pannelloContent,
            ),
          ),
        ),
      ],
    );
  }
}