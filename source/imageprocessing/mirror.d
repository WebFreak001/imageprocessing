module imageprocessing.mirror;

import imageformats : IFImage;

import std.algorithm;
import std.range;
import std.parallelism;

///
IFImage mirrorX(IFImage image)
{
	if (!image.w || !image.h)
		return image;
	IFImage ret;
	ret.w = image.w;
	ret.h = image.h;
	ret.c = image.c;
	ret.pixels.length = ret.w * ret.h * ret.c;
	foreach (row; parallel(iota(ret.h)))
		foreach (x; 0 .. ret.w)
		{
			auto dst = (row * ret.w + x) * ret.c;
			auto src = (row * ret.w + ret.w - 1 - x) * ret.c;
			ret.pixels[dst .. dst + ret.c] = image.pixels[src .. src + ret.c];
		}
	return ret;
}

///
unittest
{
	import imageformats;

	IFImage image;
	image.w = 3;
	image.h = 3;
	image.c = ColFmt.RGB;
	//dfmt off
	image.pixels = [
		11,12,13, 14,15,16, 17,18,19,
		21,22,23, 24,25,26, 27,28,29,
		31,32,33, 34,35,36, 37,38,39
	];
	//dfmt on
	auto mirrored = image.mirrorX;
	//dfmt off
	assert(mirrored.pixels == [
		17,18,19, 14,15,16, 11,12,13,
		27,28,29, 24,25,26, 21,22,23,
		37,38,39, 34,35,36, 31,32,33
	]);
	//dfmt on
}

///
IFImage mirrorY(IFImage image)
{
	if (!image.w || !image.h)
		return image;
	IFImage ret;
	ret.w = image.w;
	ret.h = image.h;
	ret.c = image.c;
	ret.pixels.length = ret.w * ret.h * ret.c;
	auto stride = ret.w * ret.c;
	foreach (row; 0 .. ret.h)
	{
		auto iRow = ret.h - 1 - row;
		ret.pixels[row * stride .. row * stride + stride]
			= image.pixels[iRow * stride .. iRow * stride + stride];
	}
	return ret;
}

///
unittest
{
	import imageformats;

	IFImage image;
	image.w = 3;
	image.h = 3;
	image.c = ColFmt.RGB;
	//dfmt off
	image.pixels = [
		11,12,13, 14,15,16, 17,18,19,
		21,22,23, 24,25,26, 27,28,29,
		31,32,33, 34,35,36, 37,38,39
	];
	//dfmt on
	auto mirrored = image.mirrorY;
	//dfmt off
	assert(mirrored.pixels == [
		31,32,33, 34,35,36, 37,38,39,
		21,22,23, 24,25,26, 27,28,29,
		11,12,13, 14,15,16, 17,18,19,
	]);
	//dfmt on
}

///
IFImage mirrorXY(IFImage image)
{
	if (!image.w || !image.h)
		return image;
	IFImage ret;
	ret.w = image.w;
	ret.h = image.h;
	ret.c = image.c;
	ret.pixels.length = ret.w * ret.h * ret.c;
	foreach (row; parallel(iota(ret.h)))
		foreach (x; 0 .. ret.w)
		{
			auto dst = ((ret.h - 1 - row) * ret.w + x) * ret.c;
			auto src = (row * ret.w + ret.w - 1 - x) * ret.c;
			ret.pixels[dst .. dst + ret.c] = image.pixels[src .. src + ret.c];
		}
	return ret;
}

///
unittest
{
	import imageformats;

	IFImage image;
	image.w = 3;
	image.h = 3;
	image.c = ColFmt.RGB;
	//dfmt off
	image.pixels = [
		11,12,13, 14,15,16, 17,18,19,
		21,22,23, 24,25,26, 27,28,29,
		31,32,33, 34,35,36, 37,38,39
	];
	//dfmt on
	auto mirrored = image.mirrorXY;
	//dfmt off
	assert(mirrored.pixels == [
		37,38,39, 34,35,36, 31,32,33,
		27,28,29, 24,25,26, 21,22,23,
		17,18,19, 14,15,16, 11,12,13
	]);
	//dfmt on
}

///
IFImage rotate90(IFImage image)
{
	if (!image.w || !image.h)
		return image;
	IFImage ret;
	ret.w = image.h;
	ret.h = image.w;
	ret.c = image.c;
	ret.pixels.length = ret.w * ret.h * ret.c;
	for (int y = 0; y < ret.h; y++)
		for (int x = 0; x < ret.w; x++)
		{
			auto dst = (x + y * ret.w) * ret.c;
			auto src = (y + (image.h - 1 - x) * image.w) * ret.c;
			ret.pixels[dst .. dst + ret.c] = image.pixels[src .. src + ret.c];
		}
	return ret;
}

///
unittest
{
	import imageformats;

	IFImage image;
	image.w = 3;
	image.h = 4;
	image.c = ColFmt.RGB;
	//dfmt off
	image.pixels = [
		11,12,13, 14,15,16, 17,18,19,
		21,22,23, 24,25,26, 27,28,29,
		31,32,33, 34,35,36, 37,38,39,
		41,42,43, 44,45,46, 47,48,49
	];
	//dfmt on
	auto mirrored = image.rotate90;
	//dfmt off
	assert(mirrored.pixels == [
		41,42,43, 31,32,33, 21,22,23, 11,12,13,
		44,45,46, 34,35,36, 24,25,26, 14,15,16,
		47,48,49, 37,38,39, 27,28,29, 17,18,19
	]);
	//dfmt on
}

///
alias rotate180 = mirrorXY;

///
IFImage rotate270(IFImage image)
{
	if (!image.w || !image.h)
		return image;
	IFImage ret;
	ret.w = image.h;
	ret.h = image.w;
	ret.c = image.c;
	ret.pixels.length = ret.w * ret.h * ret.c;
	for (int y = 0; y < ret.h; y++)
		for (int x = 0; x < ret.w; x++)
		{
			auto dst = (x + y * ret.w) * ret.c;
			auto src = ((image.w - 1 - y) + x * image.w) * ret.c;
			ret.pixels[dst .. dst + ret.c] = image.pixels[src .. src + ret.c];
		}
	return ret;
}

///
unittest
{
	import imageformats;

	IFImage image;
	image.w = 3;
	image.h = 4;
	image.c = ColFmt.RGB;
	//dfmt off
	image.pixels = [
		11,12,13, 14,15,16, 17,18,19,
		21,22,23, 24,25,26, 27,28,29,
		31,32,33, 34,35,36, 37,38,39,
		41,42,43, 44,45,46, 47,48,49
	];
	//dfmt on
	auto mirrored = image.rotate270;
	//dfmt off
	assert(mirrored.pixels == [
		17,18,19, 27,28,29, 37,38,39, 47,48,49,
		14,15,16, 24,25,26, 34,35,36, 44,45,46,
		11,12,13, 21,22,23, 31,32,33, 41,42,43
	]);
	//dfmt on
}
