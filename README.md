# README

## 📖 목차
1. [소개](#-소개)
2. [팀원](#-팀원)
3. [타임라인](#-타임라인)
4. [실행 화면](#-실행-화면)
5. [트러블 슈팅](#-트러블-슈팅)
6. [참고 링크](#-참고-링크)

</br>

## 🍀 소개
- 내 주변 음식점을 검색하며, 커스텀 하여 저장 진행
</br>

## 👨‍💻 팀원
| hamg |
| :--------: |
|<Img src="https://github.com/hemg2/ios-foodmaps/assets/101572902/80c233be-07d5-481f-9de8-0bf10fbeddc1" width="250" height="400"> |
|[Github Profile](https://github.com/Hoon94) |


</br>

## ⏰ 타임라인
|날짜|내용|
|:--:|--|
|2023.10.09| 카카오프레임워크 추가 |
|2023.10.10| 지도 마커 커스텀 CRUD 진행|
|2023.10.11| 마커 커스텀 인덱스 이슈 해결, SearchBar생성| 
|2023.10.13| 음식점API 생성 및 설정 |
|2023.10.14| 음식점API 지도에 생성 진행|
|2023.10.15| 지도 마커 커스텀 생성시 카테고리에 따라<br>커스텀이미지 생성|
|2023.10.16| 지도 이동시 중심축 이동값에 따른 API 통신 진행|
|2023.10.17| 음식점API 지도VC -> 리스트VC 구현|
|2023.10.18| READMA작성|

</br>

## 💻 실행 화면

|    |기본 화면| 이동후 음식점 불러오기|
|:--:|:--:|:--:|
|작동 화면| <img src="https://github.com/hemg2/ios-foodmaps/assets/101572902/cb65396d-5813-4921-bbfb-1342007912da" width="400" height="600"/>|<img src="https://github.com/hemg2/ios-foodmaps/assets/101572902/af1cdb6e-0890-43e4-a6b1-f486b3111ba7" width="400" height="600"/>|

|    |커스텀 마커 생성|카테고리별 통신|
|:--:|:--:|:--:|
|작동 화면|<img src="https://github.com/hemg2/ios-foodmaps/assets/101572902/f82c5259-7500-4169-9075-afc3255bc69a" width="400" height="600"/>  |<img src="https://github.com/hemg2/ios-foodmaps/assets/101572902/9715873b-9bfe-4c5d-b4cf-59a6f2917b72" width="400" height="600"/>|

</br>

## 🧨 트러블 슈팅

1️⃣ **인덱스관리**
🔒 **문제점** 
- Restaurant값, MTMapPOIItem값 따로 저장을 하다보니 인덱스 이슈로 수정 및 삭제 처리 안되었습니다.

```swift
struct Restaurant {
    var title: String
    var description: String
}
    private func setUpItemText() {
        guard let titleText = titleTextField.text,
              let descriptionText = descriptionTextView.text else { return }
            let newPoint = MTMapPOIItem()
            newPoint.itemName = title
            newPoint.mapPoint = mapPoint
            newPoint.markerType = .redPin
            
            delegate?.didAddRestaurants(title: titleText, description: descriptionText)
```
- 지도에는 추가가 되지만 인덱스가 달라 수정 및 삭제에 있어 원하는값이 안되었습니다.
<br>
🔑 **해결방법**

```swift
struct Restaurant {
    var title: String
    var description: String
}
let newPoint = MTMapPOIItem() 

2개의 값을 하나로 묶어서 관리 진행

struct RestaurantItem {
    var restaurant: Restaurant
    var poiItem: MTMapPOIItem
}

func didAddRestaurants(title: String, description: String, category: RestaurantCategory) {
        let newRestaurants = Restaurant(title: title, description: description, category: category)
        let newPoint = MTMapPOIItem()
        newPoint.itemName = title
        newPoint.userObject = description as NSObject
        newPoint.mapPoint = mapPointValue
   let restaurantItem = RestaurantItem(restaurant: newRestaurants, poiItem: newPoint)
        restaurantItems.append(restaurantItem)
```

- `RestaurantItem` 라는 객체를 통해서 한번에 인덱스 관리를 진행하여 막을수 있었습니다.
<br>

2️⃣ **CLLocation -> MAPVIEW**
🔒 **문제점**
```swift
mapView: MTMapView!, finishedMapMoveAnimation 
```
```swift
 func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
   ......
```
```swift
 private var locationManager = CLLocationManager()
        if let location = locationManager.location?.coordinate {
            components.queryItems = [
                URLQueryItem(name: "x", value: "\(location.longitude)"),
                URLQueryItem(name: "y", value: "\(location.latitude)"),
```

- 지도 이동 이후에 중심점이 변경된 지점에서 다시 서버 통신을하게 될때 나의 위치가 처음 시작위치에서 변경되지 않아 통신의 문제가 있었습니다.
- `mapView` 메서드 에서 좌표는 변하지만 변한 좌표에서 통신이 진행되지 않았으며 나의 좌표(mapView)는 변하지만 나의 좌표(CLLocation)은 변하지않은점

<br>
🔑 **해결방법**

- CLLocation 의 나의 위치를 MapView좌표에서로 변경하여 서버와의 통신을 하기 위해 변경하여 진행

```swift
  func getLocation(by mapPoint: MTMapPoint, categoryValue: String) -> URLComponents {
      ......
        
        components.queryItems = [
            URLQueryItem(name: "x", value: "\(mapPoint.mapPointGeo().longitude)"),
            URLQueryItem(name: "y", value: "\(mapPoint.mapPointGeo().latitude)"),
        ]
```

- API통신에 있어 CLLocation -> mapPoint로 변경
- 그리고 변경된 mapPoint를 인스턴스 값에 할당을 진행하여 통신을 할 수있게 진행했습니다.
```swift
private var mapPointValue = MTMapPoint()
func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        mapPointValue = mapCenterPoint
    }
```


<br>

## 📚 참고 링크
- 앱 미실행시 다운로드 [DaumMap.xcframework.zip](https://github.com/hemg2/ios-foodmaps/files/13247845/DaumMap.xcframework.zip) </br>
[카카오 지도 가이드](https://apis.map.kakao.com/ios/documentation/#MTMapView_updateCurrentLocationMarker) </br>
[지도관련 메서드](https://apis.map.kakao.com/ios/guide/) </br>
[카카오 지도 사용 블로그](https://iosminjae.tistory.com/14) </br>
[지도 추가후 빌드 이슈 블로그](https://byeon.is/swift-m1-daum-map-sdk-framework-error/) </br>
[카카오 REST API](https://developers.kakao.com/docs/latest/ko/local/dev-guide)

</br>
