# Moq samples

## Setup method expecting any object with multiple arguments in its constructor

```
this.myMockedClass
  .Setup(m => m.QueryAsync(It.Is<MyQuery>(
      query => query.ConstructorParameter1 == 1 && 
               query.ConstructorParameter2 == "a string")))
  .ReturnsYieldAsync(new List<MyResult>());
```

or if values does not matter:
```
this.myMockedClass
    .Setup(m => m.QueryAsync(It.IsAny<MyQuery>()))
    .ReturnsYieldAsync(new List<MyResult>());
```
