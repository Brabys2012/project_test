# Тестовое задание на должность «Тестировщик»

Необходимо выполнить следующие задания:
- Ознакомиться с тестами, которые находятся в папке `features`
- Выполнить задания, которые описаны в каждом feature-файле

---

## Требования

- **Ruby** 3.x (указан в `.ruby-version`)
- **Bundler** для установки зависимостей
- Для UI-тестов: **Selenoid** (Docker Compose, см. ниже)
- Для REST API-тестов: доступ к API (учётные данные в `configuration/default.yml`)

**Окружение:** на Linux доступна только командная строка (без графического интерфейса), локальный браузер запустить нельзя. UI-тесты выполняются через Selenoid в Docker.

---

## Папка examples

В каталоге `examples/` находятся **демонстрационные примеры** (видео):
- `exampe_UI_TEST_via_console.mp4` — запуск UI-тестов из консоль;
- `example_UI_TEST_SELENOID.mp4` — как проходит тест через Selenoid.

Они показывают, как выполняются сценарии в рамках этого проекта.

---

## Установка проекта

1. **Установить Ruby** (рекомендуется через rbenv или rvm):

   ```bash
   rbenv install 3.3.3   # или версия из .ruby-version
   rbenv local 3.3.3
   ```

2. **Установить зависимости**:

   ```bash
   cd /path/to/project_test
   bundle install
   ```

---

## Установка и запуск Selenoid (Docker Compose)

Selenoid запускает браузеры в Docker-контейнерах. В проекте настроен запуск через **Docker Compose**.

### Требования

- Установленные **Docker** и **Docker Compose**
- Демон Docker запущен

### Запуск

Из корня проекта:

```bash
cd /path/to/project_test
docker compose up -d
```

Будет запущено:
- **Selenoid** — `http://localhost:4444` (WebDriver Hub), образ `aerokube/selenoid:1.11.3`
- **Selenoid UI** — `http://localhost:8080` (веб-интерфейс для просмотра сессий и логов), образ `aerokube/selenoid-ui:1.10.11`

Версии образов заданы в `docker-compose.yml`.

Перед первым запуском нужно скачать образы Selenoid и Selenoid UI:

```bash
docker pull aerokube/selenoid:1.11.3
docker pull aerokube/selenoid-ui:1.10.11
```

### Скачивание образов браузеров через Docker

Перед первым запуском Selenoid нужно скачать образ браузера. В проекте по умолчанию используется Chrome 128.0.

**Скачать Chrome 128.0 (как в `selenoid/browsers.json`):**

```bash
docker pull selenoid/chrome:128.0
```

**Скачать другую версию Chrome** (например, 120.0 или 131.0):

```bash
docker pull selenoid/chrome:120.0
# или
docker pull selenoid/chrome:131.0
```

После этого добавьте или измените версию в `selenoid/browsers.json` и при запуске тестов укажите `BROWSER_VERSION=120.0` (или нужную версию).

**Список доступных образов Chrome:**  
[https://github.com/aerokube/selenoid/blob/master/docs/browser-image-amendment.adoc](https://github.com/aerokube/selenoid/blob/master/docs/browser-image-amendment.adoc)  
или на Docker Hub: [selenoid/chrome](https://hub.docker.com/r/selenoid/chrome/tags).

После скачивания образов запускайте Selenoid: `docker compose up -d`.

### Конфигурация браузеров

Файл `selenoid/browsers.json` задаёт версию Chrome (по умолчанию 128.0). Чтобы добавить другую версию или браузер, отредактируйте этот файл и перезапустите сервисы:

```bash
docker compose down
docker compose up -d
```

### Проверка

- Статус Selenoid: `curl http://localhost:4444/status`
- Веб-интерфейс: откройте в браузере `http://localhost:8080`

### Остановка

```bash
docker compose down
```

Если Selenoid запущен на другом хосте или порту, при запуске тестов задайте переменную окружения `SELENOID_URL` (см. раздел «Запуск тестов»).

---

## Запуск тестов

Из корня проекта:

```bash
cd /path/to/project_test
```

### REST API

```bash
bundle exec cucumber features/rest_api_test.feature
```

Selenoid и переменные окружения не требуются. Учётные данные для API берутся из `configuration/default.yml`.

### UI-тесты (Selenoid)

Selenoid используется по умолчанию. Перед запуском поднимите Selenoid: `docker compose up -d` (см. раздел «Установка и запуск Selenoid»).

```bash
bundle exec cucumber features/web_page_test.feature
```

Один сценарий:

```bash
bundle exec cucumber features/web_page_test.feature --name "Скачивание последнего стабильного"
```

Или

```bash
bundle exec cucumber features/web_page_test.feature:номер строки сценария
```

Версию Chrome можно задать переменной `BROWSER_VERSION` (должна совпадать с образом в Selenoid, например 128.0):

```bash
BROWSER_VERSION=128.0 bundle exec cucumber features/web_page_test.feature --name "Скачивание последнего стабильного"
```

Если Selenoid на другом хосте:

```bash
SELENOID_URL=http://your-server:4444 BROWSER_VERSION=128.0 bundle exec cucumber features/web_page_test.feature
```

### Запуск всех сценариев

```bash
bundle exec cucumber
```

Для UI-сценариев используется Selenoid.

---

## Конфигурация

| Переменная       | Описание                              | По умолчанию           |
|------------------|---------------------------------------|------------------------|
| `SELENOID_URL`   | URL Selenoid (без `/wd/hub`)          | `http://ip:4444`       |
| `BROWSER_VERSION`| Версия Chrome в Selenoid              | `128.0`                |

REST API: логин и пароль в `configuration/default.yml` в секции `:credentials`.

---

#### FAQ
1. Для работы тестов используется Ruby и его gem'ы
2. Для работы тестов требуется:
    1. Установить Ruby
    2. Установить требуемые gem'ы из файла со списком gem'ов 
    3. Проверить совместимость файла драйвера браузера и версии браузера
3. Ссылку на Ваш репозиторий с проектом и отчет присылать на почту - marina.zayceva@ediweb.com с темой письма "Тестовое задание ФИО соискателя"
4. Если у Вас возникли затруднения в процессе выполнения задания, Вы можете задать вопрос, отправив письмо на почту marina.zayceva@ediweb.com с темой "Вопросы по тестовому заданию ФИО"

#### Рекомендации
1. Для настройки и запуска тестов удобнее ОС Linux (например, Ubuntu).
2. UI-тесты запускаются только через Selenoid (Docker Compose, см. раздел «Установка и запуск Selenoid»).
