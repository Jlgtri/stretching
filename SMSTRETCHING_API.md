# SMSTRETCHING API

Инфо - все не активированные абонементы по прошествии 60 дней с даты создания будут автоматически помечаться как удаленные, это пока не работает но будет

## Абонементы

### Добавление нового абонемента (POST : json)

`https://smstretching.ru/mobile/goods/{token}/add`

Метод используется при создании нового абонемента

```json
abonement_id: {abonement_id} // int
document_id: {document_id}, // int
company_id: {company_id}, // int
phone: {user_phone} // string формат 79167777777
date_start: {date_start}, // 2021-05-25 18:40:59 формат даты, дата создания абонемента
date_end: {date_end}, // дата активации абонемена+ срок действия или пусто если active = 0 ( при этом дата окончания будет установлена равной дате создания)
active: {1 или 0} // int активирован или нет абонемент
mobile: 1 // 1 если создано с мобильного или 0 если с сайта
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"no found"} в случае неудачи.
```

### Активация абонемента (POST : json)

`https://smstretching.ru/mobile/goods/{token}/activate/{document_id}`

Метод активации абонемента (абонемент оплачен)

```json
document_id: {document_id}, // int
date_end: {date_end}, // дата активации абонемена+ срок действия
active: {1 или 0} // int активирован или нет абонемент
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"no found"} в случае если запись не найдена.
```

### Получить абонемент юзера (POST : json)

`https://smstretching.ru/mobile/goods/{token}/get_single_user`

Метод для получения данных конкретного абонемента пользователя ( вернет только абонементы с неистекшим сроком действия для активированных абонементов и не активированные абонементы)

```json
abonement_id: {abonement_id} // int
user_phone : {user_phone} // string формат 79167777777
```

```json
Возвращает массив в случае успеха
array(8) {
  id => string(3) "124" // int id записи у нас в базе
  abonement_id => string(3) "124"
  document_id =>string(5) "12312"
  company_id => string(9) "1234534"
  user_phone => string(7) "79167777777" // телефон юзера
  date_start => string(19) "2021-05-25 18:40:59" // дата создания абонемента
  date_end => string(19) "0000-00-00 00:00:00" // дата активации абонемена+ срок действия или 0000-00-00 00:00:00
  active => string(1) "1" // int 1 активирован или - не активирован абонемент
}

или {"error":"no found"} в случае ошибки
```

```txt
Внимание! Юзер может купить абонемент в подарок другому юзеру, но при этом user_phone будет другой в базе. То есть пара user_phone - abonement_id уникальна если абонемент не активирован и не истек.
```

### Получить все абонемента юзера (POST : json)

`https://smstretching.ru/mobile/goods/{token}/get_all_user`

Метод для получения данных всех абонементов пользователя

```json
user_phone : {user_phone} // string формат 79167777777
actual: {1 или 0 } // int 1 - вернет неактивированные и активированные не истекшие абонементы. 0 - вернет все подряд включая удаленные.
```

```json
Возвращает массив в случае успеха
array(9) {
  "id" => string(3) "124" // int id записи у нас в базе
  "abonement_id" => string(3) "124"
  "document_id" => string(5) "12312"
  "company_id" => string(9) "1234534"
  "user_phone" => string(7) "79167777777" // телефон юзера
  "date_start" => string(19) "2021-05-25 18:40:59" // дата создания абонемента
  "date_end" => string(19) "0000-00-00 00:00:00" // дата активации абонемена+ срок действия или 0000-00-00 00:00:00
  "active" => string(1) "1" // int 1 активирован или - не активирован абонемент
  "del" => string(1) "1" // int 1 удален 0 — не удален
}

или {"error":"no found"} в случае ошибки
```

### Получить данные всех абонементы (POST : json)

`https://smstretching.ru/mobile/goods/{token}/get_all`

Метод для получения данных всех абонементов

```json
Возвращает массив в случае успеха

array(1) {
  count => 4 // количество занятий
  service => 0 // id студии или 0 если для всех
  time => 0 // время 0 — весь день, 1 – до 16.45
  y_srok => 28 // срок действия абонемента в днях
  y_hold => 0 // возможный срок заморозки в днях
  y_id => 225112 // id абонемента в системе y_clients
  cost => 4390 // цена абонемента руб.
}

или {"error":"no found"} в случае ошибки
```

## Пользователи

### Создание нового пользователя (POST : json)

`https://smstretching.ru/mobile/users/{token}/add_user`

Метод используется при регистрации нового пользователя или для проверки существования пользователя

```json
phone: {user_phone} // string формат 79167777777
email: {user_email}, // string формат 123@123.ru
date_add : {date_add}, // 2021-05-25 18:40:59 формат даты, дата создания юзера
app_token : "sdfjsdhjk767dstfddgsdgsdg", // device token firebase или пусто если юзер с сайта
type_device : { 0 - 1 - 2 }, // тип мобильного устройства юзера 0 - если юзер с сайта 1 - android и 2 - ios
```

```json
Возвращает пустой ответ в случае успеха

или

{"true":"User exist"} если юзер уже есть в базе (идет проверка по номеру телефона). При этом будут перезаписаны поля:
email: {user_email} // string формат 123@123.ru
app_token : "sdfjsdhjk767dstfddgsdgsdg" // device token firebase или пусто если юзер с сайта
type_device : { 0 - 1 - 2}, // тип мобильного устройства юзера 0 - если юзер с сайта 1- android и 2 - ios

или

{"error":"user_no_update"} если юзер уже есть в базе но запись обновить не удалось.
```

```json
Это все нужно для ситуации когда юзер зарегался на сайте, а потом установил приложение. Или это повторная установка приложения.
То есть он уже есть у нас в базе, но при этом запросе ему добавятся (или изменятся) app_token и type_device. И также при необходимости можно изменить email.

Итого, этот медод используем при каждой установке приложения и при изменении емейла юзером.
```

### Изменить депозит пользователя (POST : json)

`https://smstretching.ru/mobile/users/{token}/edit_user_deposit`

Метод используется для изменения баланса депозита пользователя

```json
phone: {user_phone} // string формат 79167777777
user_deposit : 1200, // int сумма в руб. на балансе пользователя
```

```json
Возвращает `OK` в случае успеха или user_no_update в случае неудачи.
```

### Получить баланс депозита пользователя (POST : json)

`https://smstretching.ru/mobile/users/{token}/get_user_deposit`

Метод используется для получения баланса депозита пользователя

```json
phone: {user_phone} // string формат 79167777777
```

```json
Возвращает 1200 сумму в руб. на балансе в случае успеха
или
no found в случае неудачи.
```

## Записи

### Добавление новой записи (POST : json)

`https://smstretching.ru/mobile/records/{token}/add`

Метод используется при создании новой записи

```json
activity_id: {activity_id} // int
document_id: {document_id}, // int записи
company_id: {company_id}, // int
record_id: {record_id}, // int
date: {date}, // 2021-05-25 18:40:59 формат даты, дата и время создания записи на занятие
date_event: {date}, // 2021-05-25 18:40:59 формат даты, дата и время занятия
payment: {0 - 1 - 2 - 3}, // int тип оплаты 0 – не оплачено, 1- оплачено картой, 2 - оплачено абонементом, 3 - оплачено депозитом
abonement: {document_id} // int document_id абонемента если payment = 2 или пусто
user_phone : {user_phone} // string формат 79167777777
user_active : {0 - 1 - 2 - 3}, // 0 если юзер не подтвердил занятие ( бронь), 1 если подтвердил ( оплатил), 2 – если отменил занятие 3 - если мы отменили ( удалили) не оплаченное занятие
order_id : {order_id} // order_id успешной оплаты тинькова если payment = 1 или пусто
mobile: 1 // 1 если создано с мобильного или 0 если с сайта
rating: {от 1 до 5} // int Оценка 1-5 занятия пользователем или пусто
service_id: {service_id} // (int) service_id их метода y_clients activity/{companyId}/search/
service_name : "TRX" // string Название занятия
trener_name : "Иван Иванов" // string Имя и фамилия тренера
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"record_exist"} в случае если запись уже существует.
```

### Изменение существующей записи (POST : json)

`https://smstretching.ru/mobile/records/{token}/edit/{record_id}`

Метод используется при редактировании записи (оплата - отмена)

```json
payment: {0 - 1 - 2 - 3}, // int тип оплаты 0 – не оплачено, 1- оплачено картой, 2 - оплачено абонементом, 3 - оплачено депозитом
company_id: {company_id}, // int
user_phone : {user_phone} // string формат 79167777777
date_event: {date}, // 2021-05-25 18:40:59 формат даты, дата и время занятия
user_active : {0 - 1 - 2}, // 0 если юзер не подтвердил занятие (бронь), 1 если подтвердил (оплатил), 2 – если отменил занятие
order_id : {order_id} // order_id успешной оплаты тинькова если payment = 1 или пусто
mobile: 1 // 1 если создано с мобильного или 0 если с сайта
service_id: {service_id} // (int) service_id их метода y_clients activity/{companyId}/search/
service_name : "TRX"  // string Название занятия
trener_name : "Иван Иванов" // string Имя и фамилия тренера
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"no found"} в случае если запись не найдена.
```

### Получение существующей записи (POST : json)

`https://smstretching.ru/mobile/records/{token}/get/{record_id}`

Метод используется для получения всех данных конкретной записи

```json
user_phone : {user_phone} // string формат 79167777777
```

```json
Возвращает массив данных
или
{"error":"no found"} в случае если запись не найдена
```

### Изменение рейтинга существующей записи (POST : json)

`https://smstretching.ru/mobile/records/{token}/edit_rating/{record_id}`

Метод используется при редактировании рейтинга записи

```json
user_phone : {user_phone} // string формат 79167777777
rating: {от 1 до 5} // int Оценка 1-5 занятия пользователем или пусто
comment : {comment} // string
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"no found"} в случае если запись не найдена
```

## Лист ожидания

### Добавление новой записи в лист ожидания (POST : json)

`https://smstretching.ru/mobile/wishlist/{token}/add>`

Метод используется при создании новой записи в лист ожидания

```json
activity_id: {activity_id} // int
user_phone : {user_phone} // string формат 79167777777
add_date : {add_date}, // 2021-05-25 18:40:59 формат даты, дата создания записи в листе ожидания
activity_date : {activity_date}, // 2021-05-25 18:40:59 формат даты, дата занятия
```

```json
Возвращает пустой ответ в случае успеха
или
{"error":"record_exist"} в случае если запись уже существует
```

### Получение всех записей пользователя из листа ожидания (POST : json)

`https://smstretching.ru/mobile/wishlist/{token}/get`

Метод используется для получения записей пользователя из листа ожидания

```json
user_phone : {user_phone} // string формат 79167777777
```

```json
Возвращает массив
array(4) {
  activity_id => string(6) "123123" // activity_id
  user_phone => string(10) "7944444844" // телефон юзера
  add_date => string(19) "2021-05-25 18:40:59" // дата создания записи в листе ожидания
  activity_date => string(19) "2021-05-26 18:40:59" // дата занятия
}

или {"error":"no found"} в случае если записи не найдены
```

### Удаление записи из листа ожидания (POST : json)

`https://smstretching.ru/mobile/wishlist/{token}/delete/`

Метод используется при удалении записи из листа ожидания

```json
activity_id: {activity_id} // int
user_phone : {user_phone} // string формат 79167777777
```

```json
Возвращает пустой ответ в случае успеха
```

## ОПЦИИ

### Получение времени сервера (POST : json)

`https://smstretching.ru/mobile/options/{token}/get_time`

```txt
Возвращает время сервера в ISO8601
```

### Получение id складов и кассс (кассиров) (POST : json)

`https://smstretching.ru/mobile/options/{token}/get_all`

Метод используется для получения id складов, ID кассс и ID кассиров

```json
Возвращает массив
{
  "193064": { // ID студии
    "sklad_id":"357606", // ID склада студии
    "kassa_id":"359040", // ID кассы студии
    "kassir_site_id":"1234", // ID кассира студии для продаж с сайта
    "kassir_mobile_id":"5678", // ID кассира студии для продаж из мобильного приложения
    "category_ab_id":"645275", // ID категории товара для абонементов
    "key":"1616588130776DEMO", // TerminalKey Tinkoff для студии для мобильного приложения
    "pass":"gr6lg05oxzt0a2cp", // Password Tinkoff для студиидля мобильного приложения
    "key_site":"1616588130776DEMO", // TerminalKey Tinkoff для студии для сайта
    "pass_site":"gr6lg05oxzt0a2cp" // Password Tinkoff для студии для сайта
  },
}

или {"error":"no found"} в случае если записи не найдены
```

```txt
ID кассира используется как master_id при оформлении продажи абонемента в методах y_clients: storage_operations/operation/ и storage_operations/goods_transactions/

Внимание - этот master_id работает только для абонементов! В остальных случаях отправлять надо id тренера.

ID категории товара для абонементов испозуется для получения товаров методом y_clients API goods/{companyId}/?count=100&category_id={category_ab_id}

key - pass : Терминал тинькова для прведения платежей по студиям, сейчас данные одинаковые для всех студий ( демо) - потом будут разные.
```

### Получение полной и скидочной цены разового занятия

`https://smstretching.ru/mobile/options/{token}/get_price`

```json
Возвращает массив
{
  "regular_price":"1400",   // Полная цена разового занятия
  "y_sale_price":"500",   // Цена разового занятия со скидкой ( первичное посещение, итд)
}

или {"error":"no found"} в случае ошибки
```

## ПЛАТЕЖИ

### Создание записи (POST : json)

`https://smstretching.ru/mobile/payment/{token}/add`

Метод используется для добавления (регистрации) новой записи об оплате ДО!!! фактического проведения оплаты через Тиньков

```json
mobile: 1 // 1 если оплата с мобильного или 0 если с сайта
company_id: 123123 // ID филиала
record_id: {record_id} // record_id записи
user_phone: {user_phone} // string формат 79167777777
```

```json
Возвращает OrderID новой записи в случае успеха
{"OrderID":1279}
или
{"error":"record_exist"} в случае если запись уже существует
```

### Получение записи (POST : json)

`https://smstretching.ru/mobile/payment/{token}/get`

Метод используется для получения данных существующей записи

```json
company_id: 123123  // ID филиала
record_id: {record_id} // record_id записи
user_phone: {user_phone} // string формат 79167777777
mobile: 1 // 1 если оплата с мобильного или 0 если с сайта
```

```json
Возвращает массив в случае успеха
[
  {
    "order_id":"1300",
    "status":null,
    "canceled":"0",
    "PaymentId":null,
    "Amount":null,
    "5":null,
    "Email":null,
    "6":null,
    "Description":null,
    "7":null,
    "Redirect":null,
    "8":"N",
    "Recurrent":"N",
    "9":null,
    "Token":null,
    "10":"2021-06-06 20:48:09",
    "timestamp":"2021-06-06 20:48:09",
    "11":"33192",
    "company_id":"33192",
    "12":"1903364",
    "document_id":"1903364",
    "13":"553354",
    "record_id":"553354",
    "14":"7693308284",
    "user_phone":"7693308284"
  }
]

или

{"error":"no found"} в случае если запись не найдена
```

### Изменение записи (POST : json)

`https://smstretching.ru/mobile/payment/{token}/edit/{orderID}`

Метод используется для изменения существующей записи об оплате ПОСЛЕ!!! фактичесекого проведения оплаты через Тиньков

orderID для запроса получаем в методе Создание записи /payment/{token}/add

```json
status: "NEW" // string статус платежа из ответа тинькова CONFIRMED, NEW итд
PaymentId: 123123 // PaymentId из ответа тинькова
Amount: 12000 // int СУММА!!! платежа в копейках
Email: "123@123.com "// string email клиента
Description: "dfsdfsd" // string Описание заказа до 250 символов
Redirect: "https://securepay.tinkoff.ru/new/Z54HbmuR" // Redirect URL из ответа тинькова
Recurrent: {N или Y} // string Y если это оплата абонемента и N если это оплата одиночного занятия картой
Token: "4bb8b2b175f128bd21485a0e01eab55b3a443f2fd5db1ca040d867" // string токен из ответа тинькова
timestamp: "2021-06-06 19:07:39" // время операции в формате 2021-06-06 19:07:39
document_id: {document_id} // document_id записи или абонемента (если оплачивался абонемент)
is_abonement: {0-1} // int 0 если это запись, 1 если это абонемент
```

```json
Возвращает OK в случае успеха
{"result":"ok"}
или
{"error":"no found"} в случае если запись не найдена
```
