import 'package:attendance_app/core/services/formatted_date_and_time_services.dart';
import 'package:attendance_app/features/auth/presentations/views/widget/show_snack_bar.dart';
import 'package:attendance_app/features/chat_gpt/data/models/message.dart';
import 'package:attendance_app/features/chat_gpt/data/services/sound_services.dart';
import 'package:attendance_app/features/chat_gpt/presentation/manager/Providers/profile_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RowBottomMessage extends StatefulWidget {
  const RowBottomMessage({
    super.key,
    required this.timeSent,
    required this.message,
    required this.role,
  });

  final String timeSent;
  final String message;
  final Role role;

  @override
  State<RowBottomMessage> createState() => _RowBottomMessageState();
}

class _RowBottomMessageState extends State<RowBottomMessage> {
  final FormattedDateAndTimeServices _formattedDateAndTimeServices =
      FormattedDateAndTimeServices();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Consumer<SoundService>(
      builder: (context, soundService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AutoSizeText(
                _formattedDateAndTimeServices.formatDateTime(widget.timeSent),
                style: TextStyle(
                  color: profileProvider.isDarkMode
                      ? const Color.fromARGB(255, 172, 164, 164)
                      : const Color.fromARGB(255, 250, 233, 233),
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                if (widget.role == Role.assistant)
                  IconButton(
                    onPressed: () async {
                      if (soundService.isPlaying(widget.message)) {
                        await soundService.stop(widget.message);
                      } else {
                        await soundService.speak(
                            widget.message, widget.message);
                      }
                    },
                    icon: Icon(
                      soundService.isPlaying(widget.message)
                          ? Icons.stop
                          : Icons.volume_up,
                      color: widget.role == Role.assistant
                          ? Colors.white
                          : Colors.black,
                      size: 22,
                    ),
                  ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.message));
                    CustomSnackBar.showSuccessSnackBar(
                      context,
                      'Message copied to clipboard!',
                    );
                  },
                  icon: Icon(
                    Icons.copy,
                    color: widget.role == Role.assistant
                        ? Colors.white
                        : profileProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // لا حاجة للوصول إلى SoundService هنا، سيتم التعامل معه بواسطة Consumer
  }
}
