part of flutter_base;

enum EShapeBoxImage { rectangle, circle }

class WBoxImage extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final EShapeBoxImage shape;
  final String src;
  final BoxFit fit;

  final bool cached;
  final bool isFileFromPlugin;
  final Widget? errorBuilder;
  final String? assetImg;

  const WBoxImage({
    super.key,
    this.width,
    this.height,
    this.errorBuilder,
    this.assetImg,
    this.borderRadius,
    this.shape = EShapeBoxImage.rectangle,
    this.fit = BoxFit.fill,
    this.cached = false,
    this.isFileFromPlugin = false,
    required this.src,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    Widget error = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: shape == EShapeBoxImage.rectangle ? BoxShape.rectangle : BoxShape.circle,
      ),
      child: errorBuilder ??
          const Center(
            child: Text('No Image'),
          ),
    );

    if (!(src.startsWith('http')) || src.isEmpty) {
      child = WImageAsset(
        src: src,
        fit: fit,
        errorBuilder: error,
        assetImg: assetImg,
      );
    } else if (!cached) {
      child = WImageNetwork(
        src: src,
        fit: fit,
        width: width,
        height: height,
      );
    } else {
      child = WCachedImageNetwork(
        src: src,
        fit: fit,
        width: width,
        height: height,
        assetImg: assetImg,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape == EShapeBoxImage.rectangle ? BoxShape.rectangle : BoxShape.circle,
      ),
      // color: Colors.amber,
      child: shape == EShapeBoxImage.rectangle
          ? ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.zero,
              child: child,
            )
          : ClipOval(
              child: child,
            ),
    );
  }
}

class WImageAsset extends StatelessWidget {
  final String src;
  final BoxFit fit;
  final double? width;
  final double? height;
  final FilterQuality filterQuality;
  final BorderRadiusGeometry borderRadius;
  final Widget? errorBuilder;
  final String? assetImg;

  const WImageAsset({
    super.key,
    required this.src,
    this.fit = BoxFit.fill,
    this.width,
    this.height,
    this.errorBuilder,
    this.assetImg,
    this.borderRadius = BorderRadius.zero,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        src,
        fit: fit,
        width: width,
        height: height,
        filterQuality: filterQuality,
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (BuildContext context, error, stackTrace) {
          return assetImg != null
              ? WImageAsset(
                  src: assetImg ?? "",
                )
              : (errorBuilder ?? const SizedBox());
        },
      ),
    );
  }
}

class WImageNetwork extends StatelessWidget {
  final String? src;
  final bool isIndicatorLoading;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final double? width;
  final double? height;

  const WImageNetwork({
    super.key,
    required this.src,
    this.isIndicatorLoading = false,
    this.filterQuality = FilterQuality.low,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (src?.isEmpty ?? true) {
      return WImageAsset(
        src: AppImage.noImage,
      );
    } else {
      return Image.network(
        src!,
        width: width,
        height: height,
        filterQuality: filterQuality,
        fit: fit,
        frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return !isIndicatorLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                  ),
                );
        },
        errorBuilder: (BuildContext context, error, stackTrace) {
          return WImageAsset(
            src: AppImage.noImage,
          );
        },
      );
    }
  }
}

class WCachedImageNetwork extends StatelessWidget {
  final String? src;
  final bool isIndicatorLoading;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? assetImg;

  const WCachedImageNetwork({
    super.key,
    required this.src,
    this.isIndicatorLoading = false,
    this.filterQuality = FilterQuality.low,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.assetImg,
  });

  @override
  Widget build(BuildContext context) {
    String errImg = assetImg ?? AppImage.noImage;

    if (src?.isEmpty ?? true) {
      return WImageAsset(
        src: errImg,
      );
    } else {
      return CachedNetworkImage(
        width: width,
        height: height,
        imageUrl: src!,
        filterQuality: filterQuality,
        placeholder: !isIndicatorLoading
            ? (context, url) {
                return Container(
                  width: width ?? double.infinity,
                  height: width ?? double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                );
              }
            : null,
        progressIndicatorBuilder: isIndicatorLoading
            ? (context, url, progress) {
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.totalSize != null ? progress.downloaded / progress.totalSize! : null,
                  ),
                );
              }
            : null,
        errorWidget: (context, url, error) {
          return WImageAsset(
            src: errImg,
          );
        },
        fit: fit,
      );
    }
  }
}
