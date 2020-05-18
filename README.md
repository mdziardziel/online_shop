# README

```

## Link do aplikacji
https://online-shop-ecommerce-put.herokuapp.com

### Basic Auth
login 'poznanuniversity', hasło 'oftechnology'.

### Panel administratora
https://online-shop-ecommerce-put.herokuapp.com/admin
User: admin@example.com
Password: password


## Repozytorium git
https://github.com/mdziardziel/online_shop


## Technologie
Aplikacja została napisana w języku Ruby z pomocą frameworka RubyOnRails. Front-end jest generowany także przez RubyOnRails, dodatkowo wykorzystałem JavaScript, Jquery, sass oraz bootstrapa z nakładką material design http://daemonite.github.io/material/docs/4.1/getting-started/introduction/ .
Aplikacja została wdrożona z użyciem heroku.


## Działanie aplikacji
Sklep posiada zintegrowane płatności z payu. Kluczowa klasa, która odpowiada za integrację serwisu z PayU https://github.com/mdziardziel/online_shop/blob/master/lib/payu/payment.rb
Po lewej stronie mamy możliwość wyboru kategorii produktów które nam się wyświetlą.
Po dodaniu produktu do koszyka możemy w górnym prawym rogu przejść do koszyka lub usunąć z niego wszystkie produkty.
Po przejściu do koszyka mamy możliwość zmiany liczby wziętych produktów. Widzimy także podsumowanie koszyka, możemy potwierdzić zamówienie klikając order.
Po zamówieniu produktów widzimy podsumowanie zamówienia (na początku mamy tylko zarezerwowane produkty), status płatności, możemy kliknąć pay i opłacić zamówienia.
Po rozpoczęciu procesu płatności podajemy swoje dane potrzebne przy płatności. Możemy powrócić do zamówienia lub rozpocząć płatność z Payu.
Po rozpoczęciu płatności zostaniemy przekierowani na stronę Payu. Po wybraniu płatności blikiem możemy odrzucić albo zrealizować płatność
Po odrzuceniu płatności powrócimy na stronę zamówienia. Zamówienie będzie w stanie pending, więc możemy albo poczekać chwilę aż Payu wyśle powiadomienie do aplikacji o niepowodzeniu płatności i odświeżyć stronę, albo ręcznie anulować płatność. Po zmianie statusu transakcji na cancelled możemy pononie dokonać płatności.
Po dokonaniu płatności zostaniemy przekierowani na stronę zamówienia, po odczekaniu chwili i odświeżeniu strony status płatności powinien zmienić się na completed, a status zamówienia na paid. Wtedy też nie będziemy mieli już możliwości dokonać kolejnej zapłaty.
Zarządzać zawartością sklepu można poprzez panel administratora.

## Dokumentacja
### główny opis aplikacji, struktura
https://online-shop-ecommerce-put.herokuapp.com/doc/index.html
#### integracja z payu 
https://online-shop-ecommerce-put.herokuapp.com/doc/Payu/Payment.html
### Diagram związków encji 
![diagram](https://online-shop-ecommerce-put.herokuapp.com/doc/erd.png)
https://online-shop-ecommerce-put.herokuapp.com/doc/erd.pdf







----------------------------------------------------------------------------------------

generating documentation
```
 yardoc --private 'lib/**/*.rb' 'app/controllers/*.rb' 'app/models/*.rb' - README
```
decumentation path
```
/doc/index.html
```
erd 
```
/doc/erd.pdf
```