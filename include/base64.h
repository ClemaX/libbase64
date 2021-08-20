#pragma once

#ifndef BASE64_CHARSET
#define BASE64_CHARSET "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
#endif

char *base64_decode(const unsigned char *data, size_t *size);
