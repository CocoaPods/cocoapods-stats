#CocoaPods Stats CHANGELOG

## Master

##### Enhancements

* Send stats to the API asynchronously and out of process.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.5.3

##### Bug Fixes

* Don't raise an exception when there's no user project to pull targets from.  
  [Samuel Giddins](https://github.com/segiddins)


## 0.5.2

##### Bug Fixes

* Don't raise an exception when attempting to opt out.  
  [Samuel Giddins](https://github.com/segiddins)

## 0.5.1

##### Bug Fixes

* Skips pods that are not integrated ( and thus we can't get UUIDs )
  [Samuel Giddins](https://github.com/CocoaPods/cocoapods-stats/pull/15)


## 0.5.0

* Initial implementation of stats uploading.  
  [Orta](https://github.com/orta)

* Refactor of Orta's initial implementation
  [Segiddins](https://github.com/segiddins)
