<p align="center"><img width="748" alt="스크린샷 2022-07-26 오후 9 54 10" src="https://user-images.githubusercontent.com/107173548/181010945-6b0ac0c7-7317-4146-819b-402334ccd4e8.png"></p>

# Itree
Itree는 사용자의 일정을 관리할 수 있는 todoList 어플리케이션입니다.</br> 기본적으로 일정 추가와 삭제, 완료 여부 표시가 가능하고 추가적으로 Pinned 기능을 통해서 
매일 해야할 일로 고정하는 것도 가능합니다.</br>
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
* Core Data FrameWork
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
<img src="https://im3.ezgif.com/tmp/ezgif-3-3c1a3f321e.gif" height=400 width=250>
</p>
</br>
Add 버튼을 tap하여 calendar에서 날짜를 선택 후 일정을 입력하고 done 버튼을 누르면 리스트에 일정을 등록할 수 있습니다.
</br>

### 2. Filtering Todo
</br>
<p>
<img src="https://im3.ezgif.com/tmp/ezgif-3-c9b580af52.gif" height=400 width=250>
</p>
</br>
각 필터별로 일정들을 filtering할 수 있습니다.
</br>

### 3. Pinned and completed Todo
</br>
<p>
<img src="https://im3.ezgif.com/tmp/ezgif-3-86376a278a.gif" height=400 width=250>
</p>
</br>
왼쪽으로 swipe하여 일정을 pinned 할 수 있고, 일정을 tap하면 completed 유무를 표시할 수 있습니다.</br>
Pinned된 일정은 날짜가 지나도 사라지지 않고, list 상단에 고정되게 되며 Everyday 일정으로 변경됩니다.
</br>

### 4. Search and Delete Todo
</br>
<p>
<img src="https://im3.ezgif.com/tmp/ezgif-3-ed7c2d2e88.gif" height=400 width=250>
</p>
</br>
상단에 search bar를 사용하여 search를 할 수 있고 왼쪽으로 swipe하여 delete 버튼을 tap하게 되면 </br>
일정을 list에서 삭제할 수 있습니다.
