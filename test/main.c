#include <stdio.h>

#include <base64.h>
#include <stdlib.h>
// Demonstration of a modulo hash map with strings

int main(int ac, char **av)
{
	char	*decoded;
	size_t	size;

	if (ac == 2)
	{
		decoded = base64_decode((unsigned char *)av[1], &size);
		printf("decoded: %s\n", decoded);
		free(decoded);
	}
	return (0);
}
