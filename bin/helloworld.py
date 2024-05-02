def myjoinstr(
    param1: str,
    param2: str = ', World!',
) -> str:
    """
    Joins strings.

    @param param1: this is a first param
    @param param2: this is a second param
    @return: this is a description of what is returned
    """
    return param1 + param2


if __name__ == '__main__':
    print(myjoinstr('Hello'))
