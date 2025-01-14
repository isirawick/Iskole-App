import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iskole/core/theme/app_palette.dart';
import 'package:marquee/marquee.dart';
import 'package:iskole/core/services/notification_service.dart';

class CommonCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onPressed;
  final String? notificationTopic;

  const CommonCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onPressed,
    this.notificationTopic,
  });

  @override
  State<CommonCard> createState() => _CommonCardState();
}

class _CommonCardState extends State<CommonCard> {
  final GlobalKey _textKey = GlobalKey();
  final RxBool isOverflow = false.obs;
  final RxBool isSubscribed = false.obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.notificationTopic != null) {
      _checkSubscriptionStatus();
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    isLoading.value = true;
    final status =
        await NotificationService.isTopicSubscribed(widget.notificationTopic!);
    setState(() {
      isSubscribed.value = status;
      isLoading.value = false;
    });
  }

  Future<void> _toggleNotification() async {
    if (widget.notificationTopic == null) return;

    isLoading.value = true;
    bool success;
    if (isSubscribed.value) {
      success =
          await NotificationService.unsubscribeTopic(widget.notificationTopic!);
    } else {
      success =
          await NotificationService.subscribeTopic(widget.notificationTopic!);
    }

    if (success) {
      setState(() {
        isSubscribed.value = !isSubscribed.value;
        isLoading.value = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 3,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    placeholder: (context, text) {
                      return Image.asset(
                        "assets/images/placeholder.jpg",
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Palette.welcomeButtonTextColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Obx(
                    () => SizedBox(
                      height: 30,
                      width: Get.width,
                      child: isOverflow.value
                          ? Marquee(
                              text: widget.title,
                              blankSpace: 100,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  double maxWidth = constraints.maxWidth;

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    final RenderBox renderBox = _textKey
                                        .currentContext!
                                        .findRenderObject() as RenderBox;
                                    final textSize = renderBox.size;
                                    isOverflow.value =
                                        textSize.width > (maxWidth - 5);
                                  });
                                  return Text(
                                    widget.title,
                                    key: _textKey,
                                    overflow: TextOverflow.visible,
                                    softWrap: false,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              splashColor: Palette.gradient1.withOpacity(0.2),
              highlightColor: Palette.gradient3.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              onTap: widget.onPressed,
              child: SizedBox(
                width: Get.width,
                height: Get.width,
              ),
            ),
          ),
        ),
        if (widget.notificationTopic != null)
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: _toggleNotification,
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: !isLoading.value
                        ? Icon(
                            isSubscribed.value
                                ? Icons.notifications_active
                                : Icons.notifications_outlined,
                            color: Palette.borderColor,
                            size: 20,
                          )
                        : Container(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Palette.borderColor,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PlaceHolderCard extends CommonCard {
  PlaceHolderCard({
    super.key,
    super.title = "Placeholder",
    super.imageUrl = "https://placehold.co/600x400/000000/FFFFFF/png",
  });
}
