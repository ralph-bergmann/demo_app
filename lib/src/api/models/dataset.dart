enum DataSet {
  dataSet1(
    name: 'mock.json',
    url:
        'https://gist.githubusercontent.com/breunibes/6875e0b96a7081d1875ec1bd16c619f1/raw/9f628db3dd9606afe0d04a81f81275302481e94c/mock.json',
  ),
  dataSet2(
    name: 'gistfile1.txt',
    url:
        'https://gist.githubusercontent.com/breunibes/bd5b65cf638fc3f67b1007721ac05205/raw/77eb2dcb36bbb65e70677e1cb6620ffde5a021df/gistfile1.txt',
  );

  const DataSet({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;
}
