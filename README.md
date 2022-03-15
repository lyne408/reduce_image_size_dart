# image size reducer

## Requirements

Enable Windows Developer Mode or run as an administrator.

Recommend do the first.

## Features

### Reduce the size of an image files

By convert it to Webp high compression format, width 100 `quality`.

For **desktop(client side) usage**, not server side.

100 `quality` isn't `lossness`.

Support image formats:

This support image formats of `cwebp`, `gif2webp` of libwebp. Known:

- JPEG
- Webp
- BMP
- PNG
- GIF

### Fixed this extension of image files

Sometimes this filename `a_webp_extension_is_png.png`, rename it extension to `.webp`.

Support image formats:

- JPEG
- Webp
- BMP
- PNG
- GIF

## Usage

Download the release and extract it.

In Windows Explorer, drag an image file or directory to `reduce_image_size.exe`.

## Purpose

English: **Reduce the size of preview(gallery) images of resources(such as programs, plugins).**

简体中文: 减小资源(如软件, 插件)预览的大小.

网络存储时, 大文件传输慢.

浏览器支持. 比如放到网盘可以预览.

## Solutions

原意是想在保持原 quality, lossless/lossy 等信息的情况下,
通过转换为更高压缩比的格式,以降低图片大小.

但有时候无法估计 quality, 所以还是先转换 100 quality, 再对比原文件的大小.

> [Determine the JPEG quality factor by using Visual C# .NET](https://web.archive.org/web/20150328083839/http://support.microsoft.com:80/en-us/kb/324790)
>
> ### Retrieve the Quality Factor from a JPEG File
>
> The quality factor is not stored directly in the JPEG file, so you cannot read
> the quality factor from the file. However, you can read the quantization tables
> from the JPEG file. But even with the quantization tables, you cannot always
> determine a quality factor.
>
> You might be able to determine the quality factor by comparing the quantization tables
> against the "standard" IJG-generated tables. However, because some applications may
> use custom tables, you will not always find a match.

## High compression ratio image formats

Last edited: 22.03.05.

### AVIF

测试转换多个 PNG 图片为 Avif, Webp.

`quality` 小于约 75 时, Avif 的文件小于 Webp.

`lossness` 时, Avif 的文件大于 Webp.

### WEBP

### WEBP2

暂时还是实验性的. 并且转换很慢.

### JPEG XL

浏览器将会支持.

### HEIF

Pass. MPEG 制定的格式. 浏览器不支持.

## Known issues

### 目前不会遍历子目录

### 已知 cwebp.exe 的 `input` 只支持 ANSI 编码

已解决: 先 link `input` 文件到 ASCII 编码目录下, 再 convert.

**Command:**

```bat
cwebp.exe -q 100 "C:\Users\lyne\Downloads\Image Picka\English, 한글, 简体中文, ß🍌\1.webp"
```

**stderr:**

```text
cannot open input file 'C:\Users\lyne\Downloads\Image Picka\English, ??????\1.webp'
Error! Could not process file C:\Users\lyne\Downloads\Image Picka\English, ??????\1.webp
Error! Cannot read input picture file 'C:\Users\lyne\Downloads\Image Picka\English, ??????\1.webp'
```

即使修改 libwebp 源码, 使用 `wmain()` 添加 wide character set 支持.
依然避免不了 Windows Shell Console 的 一些 bug.
Windows 的 wide character set 不完全兼容 UTF-8.

### cwebp.exe 不能转换 Webp 动图

**stderr:**

```text
Error! Decoding of an animated WebP file is not supported.
      Use webpmux to extract the individual frames or
      vwebp to view this image.
Decoding of input data failed.
Status: 4(UNSUPPORTED_FEATURE)
Error! Could not process file 1_Worst Case.webp
Error! Cannot read input picture file '1_Worst Case.webp'
```

需要操作 C 语言, 修改 `webpmux` 或者 Dart FFI 操作 libwebp 函数.

### cwebp.exe 不能转换 APNG, PNG 动图

罕见, 不予支持.
