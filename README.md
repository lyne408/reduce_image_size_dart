# image size reducer

## Purpose

原意是想在保持原 quality, lossless/lossy 等等信息的情况下, 
通过转换为更高压缩比的格式,以降低图片大小.

浏览器支持. 比如放到网盘可以预览.

特别是网络存储, 文件大并不利.

## Solutions

若已知 lossless/lossy, quality, 则:

```dart
final options = [];
if (isLossless()) {
  options.add('-lossless');
}
final quality = getQuality();
options.add('-q $quality');
toWebp(options);

```

可知 lossless/lossy, 有些时候可以估计 quality, 有时候根本不能.

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

JPEG 只支持无损压缩.

GIF 只支持无损压缩. 但仅支持 8bit 的索引色，即在整个图片中，只能存在 256 种不同的颜色.

PNG, RAW, TIFF, 只支持无损压缩.

WEBP, AVIF 支持有损和无损压缩.

## High compression ratio image formats

Last edited: 22.03.05.

### AVIF

### WEBP

### WEBP2

暂时还是实验性的. 并且转换很慢.

### JPEG XL

浏览器将会支持.

### HEIF

Pass. MPEG 制定的格式. 浏览器不支持.

## Known issues

- ### 已知 cwebp.exe 的 `input` 只支持 ANSI 编码

  比如在 Windows 10 不开启 UTF-8 编码时, 路径为英文或中文都没有问题, 
  但其他语言如韩文, 特殊符号不能识别.
  
  以后再解决.

  **Command:**

  ```bat
  cwebp.exe -q 100 "C:\Users\lyne\Downloads\Image Picka\한글\1.webp"
  ```

  **stderr:**

  ```text
  cannot open input file 'C:\Users\lyne\Downloads\Image Picka\??\1.webp'
  Error! Could not process file C:\Users\lyne\Downloads\Image Picka\??\1.webp
  Error! Cannot read input picture file 'C:\Users\lyne\Downloads\Image Picka\??\1.webp'
  ```

- ### cwebp.exe 不能转换 webp 动图

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
