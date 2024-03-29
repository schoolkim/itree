<p align="center"><img width="748" alt="스크린샷 2022-07-26 오후 9 54 10" src="https://user-images.githubusercontent.com/107173548/181010945-6b0ac0c7-7317-4146-819b-402334ccd4e8.png"></p>


# Itree
Itree는 사용자의 일정을 관리할 수 있는 todoList 어플리케이션입니다.</br> 기본적으로 일정 추가와 삭제, 완료 여부 표시가 가능하고 추가적으로 </br>
Pinned 기능을 통해서 매일 해야할 일로 고정하는 것도 가능합니다.</br>
등록한 일정을 검색할 수 있는 검색 기능과 4가지의 필터를 통해서 기간별 필터링한 결과를 확인할 수도 있습니다.
</br>
</br>
</br>

# Table of contents
* [Tech Stack](#teck-stack)
* [Basic Concept](#basic-concept)
* [Application Architecture](#architecture)
* [Simulation](#simulation)
</br>
</br>

<a name="teck-stack"/>

## Tech Stack
* Swift 5.6
* Core Data Framework
</br>

<a name="basic-concept"/>

## Basic Concept
<p align="center"><img width="1178" alt="스크린샷 2022-07-27 오후 7 06 14" src="https://user-images.githubusercontent.com/107173548/181224182-d903bc75-48db-49ea-a377-92358b90c1eb.png"></p>
</br>
기본적으로 MVC 패턴을 활용하여 View로부터 UserAction이 발생하면 Controller의 동작을 통해 Model을 </br> 
Update되고 Model의 Update가 완료되면 Controller를 통해 다시 Update된 사항이 View를 통해 사용자에게 보여지게 됩니다.
</br>
</br>
</br>

```
@objc
func tappedDoneButton() {
  ...
  coreDataStore.createTodo()
  ...
}

func createTodo() {
  ...
}
```
</br>
</br>
예시로 일정을 추가하는 코드를 살펴보면 View를 통해서 tap 액션이 발생하면 Controller의 tapped 함수를 호출해서</br> 
coreData Model의 데이터가 update되고 View를 통해 보여지게 됩니다.
</br>

<a name="architecture"/>

## Application architecture
<p align="center"><img width="1326" alt="스크린샷 2022-07-29 오후 5 53 18" src="https://user-images.githubusercontent.com/107173548/181722858-95f9c6c4-fe28-4836-b315-8c8a11ba5da7.png"></p>
</br>
기본적인 application architecture로 View와 HomeViewController와 CoreData를 MVC 패턴을 활용하여 구성하였습니다.
</br>

<a name="simulation"/>

## Simulation
### 1. Add Todo
</br>
<p>
<img src="https://user-images.githubusercontent.com/107173548/182122923-5d220969-693f-484c-a196-ddba78b8f437.gif" height=400 width=250>
</p>
</br>
Add 버튼을 tap하여 calendar에서 날짜를 선택 후 일정을 입력하고</br> 
done 버튼을 누르면 리스트에 일정을 등록할 수 있습니다.</br>
버튼을 탭한 뒤 키보드 위 위치한 날짜와 시간을 선택할 수 있는 </br>
캘린더 버튼을 통해 날짜와 시간을 선택하고 할 일을 입력합니다. 
</br>

### 2. Filtering Todo
</br>
<p>
<img src="https://user-images.githubusercontent.com/107173548/182124662-12407a76-7175-43f4-8637-22e635635c94.gif" height=400 width=250>
</p>

</br>
각 필터별로 일정들을 filtering할 수 있습니다.</br>
필터는 4가지로, 전체, 오늘해야할 일정, 이번 주 일정, 이번 달 일정 순입니다.
</br>

### 3. Pinned and completed Todo
</br>
<p>
<img src="https://user-images.githubusercontent.com/107173548/182125413-f58ea467-25ab-420c-857f-0d4f0aa4932b.gif" height=400 width=250>
</p>
</br>
왼쪽으로 swipe하여 일정을 pinned 할 수 있고, </br>
일정을 tap하면 completed 유무를 표시할 수 있습니다.</br>
원하는 일정을 왼쪽으로 밀면 고정 할 수 있는 버튼이 생기며</br>
상단에 고정한 일정은 매일 해야할 일정으로 변경되고</br>
완료한 일정은 해당 일정을 탭하여 완료 여부를 표시할 수 있습니다.
</br>

### 4. Search and Delete Todo
</br>
<p>
<img src="https://user-images.githubusercontent.com/107173548/182126019-614d62de-f34d-4d69-88e5-e2f86a2b40b7.gif" height=400 width=250>
</p>
</br>
일정을 삭제할 수 있고 일정을 검색할 수 있습니다.</br>
원하는 일정을 왼쪽으로 밀어 삭제 버튼을 탭할 수 있으며</br>
화면 상단에 위치한 검색 바에서 검색 기능을 사용할 수 있습니다.
</br>
</br>

**개인정보처리방침**
file:///Users/hakkyukim/Downloads/Itree+%25EA%25B0%259C%25EC%259D%25B8%25EC%25A0%2595%25EB%25B3%25B4+%25EC%25B2%2598%25EB%25A6%25AC%25EB%25B0%25A9%25EC%25B9%25A8.html

