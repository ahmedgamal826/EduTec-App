import 'dart:io';
import 'package:attendance_app/core/provider/chat_provider.dart';
import 'package:attendance_app/features/chat_gpt/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImagesPreviewWidget extends StatelessWidget {
  const ImagesPreviewWidget({super.key, this.message});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final imagesShow =
            message != null ? message!.imagesUrls : chatProvider.imagesFileList;
        final padding = message != null
            ? EdgeInsets.zero
            : const EdgeInsets.only(right: 8, left: 8);

        return Padding(
          padding: padding,
          child: SizedBox(
            height: screenWidth * 0.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagesShow!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(
                        message != null
                            ? message!.imagesUrls[index]
                            : chatProvider.imagesFileList![index].path,
                      ),
                      width: screenWidth * 0.3,
                      height: screenWidth * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
