// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final String title;
  final List<String> listOfValues;
  final String placeholder;
  final Function(String) onSelected;

  const SearchableDropdown({
    super.key,
    required this.title,
    required this.listOfValues,
    required this.placeholder,
    required this.onSelected,
  });

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _controller = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<String> filteredData = [];
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filterData);
    _focusNode.addListener(_handleFocusChange);
  }

  void _filterData() {
    String query = _controller.text;
    if (query.isNotEmpty) {
      List<String> tmpList = widget.listOfValues
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (tmpList.isNotEmpty) {
        filteredData = tmpList;
        if (_overlayEntry == null) {
          _showOverlay();
        } else {
          _overlayEntry!.markNeedsBuild(); // Refresh the overlay
        }
      } else {
        _removeOverlay();
      }
    } else {
      _removeOverlay();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width:
            size.width, // Set the width of the overlay to match the TextField
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5), // Adjust for precise positioning
          child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      200, // Maximum height for the overlay to be scrollable
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: filteredData
                      .map((item) => ListTile(
                            title: Text(item),
                            onTap: () {
                              _controller.text = item;
                              widget.onSelected(item);
                              if (['Convener', 'Team Member', 'Department']
                                  .contains(widget.title)) {
                                _controller.text = '';
                              }
                              _removeOverlay();
                            },
                          ))
                      .toList(),
                ),
              )),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // if (mounted) {
    //   setState(() => filteredData = []);
    // }
  }

  @override
  void dispose() {
    _controller.removeListener(_filterData);
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            key: _textFieldKey,
            controller: _controller,
            onChanged: (value) {
              if (!['Convener', 'Team Member', 'Department']
                  .contains(widget.title)) {
                widget.onSelected(value);
              }
            },
            decoration: InputDecoration(
              labelText: widget.placeholder,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CustomButton extends StatefulWidget {
  ValueNotifier<bool> processing = ValueNotifier(false);
  final String title;
  final Function onPress;
  CustomButton({super.key, required this.title, required this.onPress});
  @override
  _CustomButton createState() => _CustomButton();
}

class _CustomButton extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(6),
        child: ValueListenableBuilder(
            valueListenable: widget.processing,
            builder: (context, isProcessing, child) {
              return isProcessing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        widget.processing.value = true;
                        widget.onPress();
                        widget.processing.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: Text(
                        widget.title,
                        style:
                            const TextStyle(fontSize: 17, color: Colors.white),
                      ));
            }));
  }
}
