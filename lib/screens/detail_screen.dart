import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/post.dart';
import '../core/device_utils.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isDownloading = false;

  Future<void> _downloadRaw() async {
    setState(() => _isDownloading = true);
    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = "raw_${widget.post.id}.jpg";
      final path = "${dir.path}/$fileName";

      await dio.download(widget.post.rawUrl, path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to $path"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cacheWidth = DeviceUtils.getCacheWidth(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Detail")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'post-image-${widget.post.id}',
              child: CachedNetworkImage(
                imageUrl: widget.post.mobileUrl,
                memCacheWidth: cacheWidth,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (context, url) => CachedNetworkImage(
                  imageUrl: widget.post.thumbUrl,
                  memCacheWidth: cacheWidth,
                  fit: BoxFit.contain,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fadeOutDuration: const Duration(milliseconds: 300),
                fadeInDuration: const Duration(milliseconds: 700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Post ID: ${widget.post.id}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Created: ${widget.post.createdAt}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadRaw,
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isDownloading ? "Downloading..." : "Download High-Res (Raw)"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
