<h1 align="center">My Places</h1>

Я в соц. сетях:
<p align="center">

[![](https://upload.wikimedia.org/wikipedia/commons/4/4e/VK_Compact_Logo.svg)](https://vk.com/berestnev_v)

[![](https://upload.wikimedia.org/wikipedia/commons/8/83/Telegram_2019_Logo.svg =50x)](https://t.me/berestnev_v)

</p>
<h2> Описание </h2>

<p align="center">

Это учебное приложение, в котором конечному пользователю нет нужды, однако моей задачей было добавить в него те функции, которые я хотел (и должен был бы) увидеть в реально работающем коммерческом приложении.
В нём пользователь может сохранять информацию о полюбившихся ему местах (ресторанах, парках, кинотеатрах, и т.п.): присваивать им фотографии, названия, геолокацию, рейтинг, и категории.
Реализован поиск по названиям/категориям; фильтрация по категориям; возможность прокладывать маршрут по местоположению через MKMapView.
Данные хранятся с помощью Realm. 
_______________________________________________________________
This is a sample application that the end user does not need, but my task was to add the functions that I wanted (and should) see in a real working commercial application:
In it, the user can save information about places he likes (restaurants, parks, cinemas, etc.): assign them photos, names, geolocation, rating, and categories.
Search by name / category has been implemented; filtering by category; the ability to plot a route by location via MKMapView.
The data is stored using Realm. 

## Контроллеры представления

### MainTableVC

<p align="center">
<img src="MyPlaces/ReadmeAssets/Main">
</p>

На этом экране отображаются добавленные пользователем места. Сверху есть фильтрация по категориям и поиск по свайпу вниз. Рядом с каждым заведением отображается рейтинг и категория, которые выбрал пользователь.

<p align="center">
<img src="MyPlaces/ReadmeAssets/Search">
</p>


### AddNewCellTVC
<p align="center">
<img src="MyPlaces/ReadmeAssets/AddNewCell">
</p>
Экран, на котором пользователь взаимодействует с добавляемым местом. Геолокацию можно вбить вручную или выбрать на карте. 
Инпутом для выбора категории служит UIPickerView. Категории загружаются с помощью функции 
```Swift
getTypes()
```
которая отображает категории в зависимости от типа места, который выбирает пользователь (Рестораны/Развлечения/Парки и аттракционы) .
<p align="center">
<img src="MyPlaces/ReadmeAssets/KeyboardPickerView">
</p>
