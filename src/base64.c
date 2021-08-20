#include <stdlib.h>
#include <string.h>

#include <stdio.h>

#include <base64.h>

size_t	base64_size(const char *map, const unsigned char *data)
{
	size_t	size;
	size_t	length;

	length = 0;

	while (map[data[length]] != -1)
		length++;


	if (data[length] == '=' && length % 4 != 0)
	{
		size = length / 4 * 3 + 1 + (data[length + 1] != '=');
		length += 1 + (data[length + 1] == '=');

		if (length % 4 != 0 || data[length] != '\0')
			size = 0;
	}
	else if (data[length] == '\0' && length % 4 == 0)
		size = length / 4 * 3;
	else
		size = 0;

	return size;
}

void	base64_init_map(char map[256])
{
	static const unsigned char	table[64] = BASE64_CHARSET;

	memset(map, -1, sizeof(*map) * 255);
	for (size_t i = 0; i < sizeof(table); i++)
		map[table[i]] = i;
}

char *base64_decode(const unsigned char *data, size_t *size)
{
	static char		map[256] = "";
	char			*dest;
	size_t			i;

	if (map[0] == '\0')
		base64_init_map(map);
	*size = base64_size(map, data);
	if (*size != 0)
	{
		dest = malloc(sizeof(*dest) * (*size + 1));

		if (dest != NULL)
		{
			i = 0;
			while (*data != '\0')
			{
				dest[i++] = map[data[0]] << 2 | map[data[1]] >> 4;
				if (data[2] != '=')
				{
					dest[i++] = map[data[1]] << 4 | map[data[2]] >> 2;
					if (data[3] != '=')
						dest[i++] = ((map[data[2]] << 6) & 0xc0) | map[data[3]];
				}
				data += 4;
			}
			dest[i] = '\0';
			printf("\n");
		}
	}
	else
		dest = NULL;

	return dest;
}