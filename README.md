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
* [Simulation](#simulation)
</br>
</br>

<a name="teck-stack"/>

## Tech Stack
* Swift 5.6
* Core Data FrameWork

<a name="basic-concept"/>

## Basic Concept
<p align="center"><img width="1178" alt="스크린샷 2022-07-27 오후 7 06 14" src="https://user-images.githubusercontent.com/107173548/181224182-d903bc75-48db-49ea-a377-92358b90c1eb.png"></p>
기본적으로 MVC 패턴을 활용하여 View로부터 UserAction이 발생하면 Controller의 동작을 통해 Model을 Update되고 Model의 Update가 완료되면 Controller를 통해 다시 Update된 사항이 View를 통해 사용자에게 보여지게 됩니다.
