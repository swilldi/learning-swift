# Swift в консоли

Курс о том, как писать на Swift без Xcode, только с терминалом и текстовым редактором. После него вы будете уверенно создавать пакеты, подключать библиотеки, разбивать код на модули, писать тесты, корректно замерять время работы кода, отлаживать программу и собирать полноценные консольные утилиты.

**Как проходить.** Идите по порядку и весь код набирайте руками, а не копируйте. Каждый урок заканчивается разделом «Практика». Задания там необязательны для продолжения: код следующего урока от них не зависит. Но именно на них материал и усваивается.

**Сквозной проект: `wordy`.** Это утилита частотного анализа текста: она читает текст и выводит самые частые слова. За курс она вырастет из скрипта на 10 строк в пакет с библиотекой, внешней зависимостью, тестами, замерами производительности и нормальным интерфейсом командной строки.

```
$ wordy book.txt --top 5 --min-length 4
that    1204
with     987
have     701
this     688
from     512
```

**Содержание**

- Часть I. Основы
  - [Урок 0. Окружение](#урок-0-окружение)
  - [Урок 1. Swift без пакета: скрипты и swiftc](#урок-1-swift-без-пакета-скрипты-и-swiftc)
  - [Урок 2. Первый пакет](#урок-2-первый-пакет)
  - [Урок 3. Package.swift построчно](#урок-3-packageswift-построчно)
  - [Урок 4. Основные команды](#урок-4-основные-команды)
- Часть II. Рабочий уровень
  - [Урок 5. Модули: библиотека и программа](#урок-5-модули-библиотека-и-программа)
  - [Урок 6. Зависимости](#урок-6-зависимости)
  - [Урок 7. Замеры времени](#урок-7-замеры-времени)
  - [Урок 8. Тесты](#урок-8-тесты)
  - [Урок 9. Аргументы, ввод и вывод, файлы](#урок-9-аргументы-ввод-и-вывод-файлы)
- Часть III. Инструменты
  - [Урок 10. Редактор](#урок-10-редактор)
  - [Урок 11. Отладка в lldb](#урок-11-отладка-в-lldb)
  - [Урок 12. Ресурсы, форматирование, когда всё сломалось](#урок-12-ресурсы-форматирование-когда-всё-сломалось)
- [Итог: проект целиком](#итог-проект-целиком)
- [Финальное задание](#финальное-задание)
- [Шпаргалка](#шпаргалка)
- [Источники и что почитать дальше](#источники-и-что-почитать-дальше)

---

# Часть I. Основы

## Урок 0. Окружение

Сначала убедимся, что Swift установлен и вызывается из терминала.

```bash
swift --version
```

На macOS Swift поставляется вместе с Xcode или с Command Line Tools. Если команда не найдена, установите инструменты:

```bash
xcode-select --install
```

Если установлен Xcode, полезно знать, какой именно Swift вызывается и откуда:

```bash
xcode-select -p          # путь к активным инструментам разработчика
xcrun --find swift       # полный путь к swift
```

Второй вариант установки — **swiftly**, официальный менеджер версий Swift. Он ставит Swift отдельно от Xcode и умеет держать несколько версий одновременно:

```bash
swiftly install latest        # поставить последний релиз
swiftly install --use 6.0     # поставить конкретную версию и сделать её активной
swiftly use 6.0               # переключиться на установленную версию
```

Для курса подойдёт любой вариант. swiftly пригодится, если какой-то проект требует определённую версию Swift.

> **Нужно знать: что такое toolchain.** Toolchain — это комплект инструментов одной версии: компилятор `swiftc`, менеджер пакетов SwiftPM (команды `swift build`, `swift run` и т. д.), отладчик `lldb`, языковой сервер `sourcekit-lsp` для редакторов и форматтер `swift format`. Когда вы переключаете версию Swift, меняется весь комплект.

Подробнее: [Getting Started with Swiftly on macOS](https://swift.org/install/macos/swiftly/)

### Практика

1. Выясните, какая версия Swift у вас стоит и где лежит бинарник `swift`. Готово, когда вы можете назвать версию и путь.
2. Найдите, где лежит отладчик `lldb` из того же toolchain.
   <details><summary>Подсказка</summary>Та же команда, которой вы искали <code>swift</code>.</details>

---

## Урок 1. Swift без пакета: скрипты и swiftc

Для быстрых экспериментов пакет не нужен, хватает одного файла. С него и начнётся `wordy`.

Создайте файл `count.swift`:

```swift
let text = """
Swift is a general purpose language. Swift is fast, \
and Swift is safe. Fast code is good code.
"""

// разбиваем на слова: всё, что не буква, считаем разделителем
let words = text
    .lowercased()
    .split(whereSeparator: { !$0.isLetter })
    .map(String.init)

var counts: [String: Int] = [:]
for word in words {
    counts[word, default: 0] += 1
}

for (word, count) in counts.sorted(by: { $0.value > $1.value }).prefix(3) {
    print(word, count)
}
```

**Запуск как скрипта.** Файл компилируется в памяти и сразу выполняется:

```bash
swift count.swift
```

**Компиляция в бинарник** через компилятор `swiftc`:

```bash
swiftc count.swift -o count        # без оптимизаций
swiftc -O count.swift -o count     # с оптимизациями
./count
```

**REPL** — интерактивная консоль, удобная, чтобы проверить пару выражений. Запускается командой `swift repl`, выход через `:quit`.

Почему одного файла скоро станет мало: как только появятся второй файл, внешняя библиотека или тесты, придётся вручную перечислять все файлы для `swiftc`, искать библиотеки и указывать пути к ним. Эту работу берёт на себя пакет.

> Слова с одинаковой частотой выводятся в случайном порядке, потому что словарь в Swift не упорядочен. Если запустить скрипт несколько раз, порядок может меняться. Мы исправим это в уроке 5.

Подробнее: [Build a Command-line Tool (swift.org)](https://www.swift.org/getting-started/cli-swiftpm/)

### Практика

1. Добавьте в скрипт вывод общего числа слов и числа **разных** слов. Готово, когда для текста выше получится 18 и 11.
2. Скомпилируйте скрипт через `swiftc` в два бинарника: без оптимизаций и с `-O`. Сравните их размер командой `ls -lh`.
3. `(*)` Сделайте так, чтобы при равной частоте слова выводились по алфавиту.
   <details><summary>Подсказка</summary>В замыкании для <code>sorted(by:)</code> сначала сравните частоты, а если они равны — сами слова.</details>

---

## Урок 2. Первый пакет

**Пакет** — это папка с файлом `Package.swift`, в котором описано, из каких частей состоит проект и как его собирать. Собирает пакет **SwiftPM** (Swift Package Manager). Он входит в Swift и вызывается командами `swift build`, `swift run` и другими.

```bash
mkdir Wordy && cd Wordy
swift package init --name Wordy --type executable
```

Получится такая структура:

```
Wordy/
├── Package.swift     ← манифест пакета
├── .gitignore        ← уже исключает .build/
└── Sources/
    └── main.swift    ← точка входа, здесь "Hello, world!"
```

Запустите пакет:

```bash
swift run
```

Первая сборка займёт несколько секунд, следующие пойдут быстрее. Всё, что собирается, складывается в скрытую папку `.build/`.

Теперь перенесите код из `count.swift` в `Sources/main.swift` и снова выполните `swift run`. Это первая версия `wordy` в виде пакета.

Какие ещё бывают шаблоны:

| `--type` | Что создаёт |
|---|---|
| `executable` | программу с `main.swift` |
| `library` | библиотеку и тесты к ней |
| `tool` | программу, сразу подключённую к ArgumentParser (урок 9) |
| `empty` | только манифест |

Подробнее: [Swift Package Manager — документация](https://www.swift.org/documentation/package-manager/)

### Практика

1. Создайте в отдельной папке пакет с типом `library` и сравните его структуру и `Package.swift` с пакетом `Wordy`. Готово, когда вы можете назвать два отличия.
2. Найдите в `.build/` собранный бинарник `Wordy` и запустите его напрямую, без `swift run`.
   <details><summary>Подсказка</summary>Он лежит в папке, название которой связано с режимом сборки по умолчанию.</details>

---

## Урок 3. Package.swift построчно

Откройте `Package.swift`. С точностью до комментариев он выглядит примерно так:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Wordy",
    targets: [
        .executableTarget(
            name: "Wordy",
            path: "Sources"
        ),
    ]
)
```

Разберём каждую строку.

**`// swift-tools-version: 6.0`** — несмотря на вид комментария, это обязательная строка, и стоять она должна первой. Она задаёт минимальную версию SwiftPM, которая нужна для сборки, и набор доступных возможностей манифеста. Начиная с `6.0` код компилируется в языковом режиме Swift 6 со строгой проверкой конкурентности.

**`import PackageDescription`** — подключает API для описания пакета.

**`let package = Package(...)`** — переменная должна называться именно `package`, по этому имени её ищет SwiftPM. Сам манифест — обычный код на Swift, который SwiftPM выполняет, чтобы узнать структуру пакета.

**`name`** — имя пакета.

**`targets`** — список **таргетов**. Таргет — это единица сборки: набор исходников, который компилируется в один модуль. Основные виды:

| Таргет | Что это |
|---|---|
| `.executableTarget` | программа с точкой входа |
| `.target` | библиотечный модуль, который можно импортировать |
| `.testTarget` | тесты |

**`path:`** — где лежит код таргета. По умолчанию это `Sources/<ИмяТаргета>/`, а у тестов `Tests/<ИмяТаргета>/`. Шаблон кладёт код прямо в `Sources/`, поэтому явно указывает путь. Если в вашей версии Swift строки `path` нет — тоже нормально: SwiftPM разрешает класть код прямо в `Sources/`, если таргет в пакете один.

Полный скелет манифеста со всеми основными полями. Каждое поле мы разберём в своё время:

```swift
let package = Package(
    name: "Wordy",
    platforms: [.macOS(.v14)],   // минимальная версия ОС
    products: [ ],               // что пакет отдаёт другим пакетам (урок 5)
    dependencies: [ ],           // внешние пакеты (урок 6)
    targets: [ ]                 // модули
)
```

**Точка входа** у программы бывает двух видов:

- файл с именем `main.swift`: код в нём выполняется сверху вниз, как скрипт;
- тип с атрибутом `@main` в файле с любым другим именем:

```swift
@main
struct App {
    static func main() {
        print("старт")
    }
}
```

> Одновременно `main.swift` и `@main` в одном таргете быть не может. Это одна из самых частых ошибок, и мы встретим её в уроке 9.

Подробнее: [PackageDescription (Apple)](https://developer.apple.com/documentation/packagedescription), [The Missing SPM Syntax Cheatsheet](https://swifttoolkit.dev/posts/spm-cheatsheet)

### Практика

1. Добавьте в манифест `platforms: [.macOS(.v14)]` и убедитесь, что пакет собирается.
2. Переделайте `Wordy` на точку входа через `@main`: переименуйте `main.swift`, заверните код в `static func main()`. Готово, когда `swift run` выводит то же, что и раньше.
   <details><summary>Подсказка</summary>Если файл после переименования всё ещё называется <code>main.swift</code>, будет ошибка. Назовите его, например, <code>Wordy.swift</code>.</details>
3. `(*)` Сломайте манифест: опечатайтесь в `executableTarget` и выполните `swift build`. Посмотрите, как выглядит ошибка компиляции манифеста, затем почините.

---

## Урок 4. Основные команды

Команды, которыми вы будете пользоваться постоянно:

```bash
swift build                    # собрать (debug)
swift build -c release         # собрать с оптимизациями
swift run                      # собрать и запустить
swift run -c release           # то же, в release
swift run Wordy arg1 arg2      # запустить конкретный исполняемый таргет с аргументами
```

Команды для обслуживания пакета:

```bash
swift package clean            # удалить результаты сборки (зависимости останутся)
swift package reset            # удалить .build целиком, вместе со скачанными зависимостями
swift package describe         # как SwiftPM понял ваш манифест
swift build --show-bin-path    # где лежат бинарники
```

После сборки бинарники лежат здесь:

```
.build/debug/Wordy
.build/release/Wordy
```

**Debug и release.** Debug-сборка компилируется быстро, сохраняет информацию для отладчика и почти ничего не оптимизирует. Release-сборка компилируется дольше, зато работает намного быстрее, иногда в десятки раз. Для разработки берите debug, для замеров скорости и итогового бинарника — только release.

Подробнее: [Swift Package Manager — документация](https://www.swift.org/documentation/package-manager/)

### Практика

1. Соберите `Wordy` в debug и в release и запустите оба бинарника напрямую из `.build/`, каждый через `time`. Готово, когда оба работают и вы сравнили время.
2. Выясните, что `swift package describe` выводит про ваш таргет: тип, путь, список файлов.
3. `(*)` Сделайте текст в 100 000 раз длиннее: `let text = String(repeating: "...", count: 100_000)`. Снова сравните debug и release через `time`. Во сколько раз они различаются теперь?

---

# Часть II. Рабочий уровень

## Урок 5. Модули: библиотека и программа

Разделим `wordy` на две части:

- **`WordyCore`** — библиотека со всей логикой: разбиение на слова, подсчёт частот, выбор топа;
- **`Wordy`** — программа, которая только вызывает библиотеку и печатает результат.

Зачем это нужно: логику в библиотеке можно тестировать (урок 8), замерять (урок 7) и использовать из нескольких программ.

```
Wordy/
├── Package.swift
└── Sources/
    ├── WordyCore/
    │   └── WordyCore.swift
    └── Wordy/
        └── main.swift
```

Создайте папки и перенесите `main.swift` (если в уроке 3 вы переделали его на `@main`, верните обратно `main.swift`, так проще). Манифест:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Wordy",
    platforms: [.macOS(.v14)],
    targets: [
        .target(name: "WordyCore"),
        .executableTarget(name: "Wordy", dependencies: ["WordyCore"]),
    ]
)
```

`path` больше не нужен: каждый таргет лежит в стандартной папке `Sources/<Имя>/`. Строка `dependencies: ["WordyCore"]` говорит, что `Wordy` использует модуль `WordyCore`.

Библиотека:

```swift
// Sources/WordyCore/WordyCore.swift

/// Разбивает текст на слова в нижнем регистре.
public func words(in text: String) -> [String] {
    text.lowercased()
        .split(whereSeparator: { !$0.isLetter })
        .map(String.init)
}

/// Считает, сколько раз встречается каждое слово.
public func frequencies(of words: [String]) -> [String: Int] {
    var counts: [String: Int] = [:]
    for word in words {
        counts[word, default: 0] += 1
    }
    return counts
}

/// Слово и его частота. «Больше» значит «встречается чаще»;
/// при равной частоте больше то слово, которое раньше по алфавиту.
public struct WordCount: Comparable, Sendable {
    public let word: String
    public let count: Int

    public init(word: String, count: Int) {
        self.word = word
        self.count = count
    }

    public static func < (lhs: WordCount, rhs: WordCount) -> Bool {
        lhs.count != rhs.count ? lhs.count < rhs.count : lhs.word > rhs.word
    }
}

/// Топ слов через полную сортировку.
public func topWordsSorted(_ counts: [String: Int], limit: Int) -> [WordCount] {
    let all = counts.map { WordCount(word: $0.key, count: $0.value) }
    return Array(all.sorted(by: >).prefix(limit))
}
```

Программа:

```swift
// Sources/Wordy/main.swift
import WordyCore

let text = """
Swift is a general purpose language. Swift is fast, \
and Swift is safe. Fast code is good code.
"""

let counts = frequencies(of: words(in: text))
for item in topWordsSorted(counts, limit: 3) {
    print(item.word, item.count)
}
```

Благодаря сравнению в `WordCount` порядок вывода стал детерминированным, то есть одинаковым при каждом запуске.

### Уровни доступа

Модуль — это граница видимости. По умолчанию всё объявленное имеет уровень `internal` и видно только внутри своего модуля. Поэтому всё, что `Wordy` вызывает из `WordyCore`, помечено `public`.

| Уровень | Где видно |
|---|---|
| `private` | внутри объявления (и его расширений в том же файле) |
| `fileprivate` | внутри файла |
| `internal` (по умолчанию) | внутри модуля |
| `package` | во всех модулях этого пакета |
| `public` | везде, где модуль импортирован |
| `open` | как `public`, плюс можно наследоваться от класса и переопределять его методы снаружи |

> **Ловушка с инициализатором.** Для структуры Swift сам генерирует поэлементный инициализатор (`WordCount(word:count:)`), но он всегда `internal`, даже если структура `public`. Поэтому в `WordCount` инициализатор написан вручную и помечен `public`. Без этого создать `WordCount` из другого модуля не получится.

### Products

Внутри одного пакета таргеты ссылаются друг на друга напрямую по имени, как `"WordyCore"` выше. Раздел `products` нужен, только когда вашим модулем будет пользоваться **другой пакет**:

```swift
products: [
    .library(name: "WordyCore", targets: ["WordyCore"]),
],
```

Подробнее: [Access Control (The Swift Programming Language)](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol/)

### Практика

1. Уберите `public` у `frequencies` и соберите проект. Прочитайте ошибку. Затем замените `public` на `package`. Готово, когда вы можете объяснить, почему с `package` код собирается.
2. Добавьте в `WordyCore` функцию `uniqueWordCount(in:)` и выведите её результат в программе.
3. `(*)` Добавьте в пакет второй исполняемый таргет `WordyStats`, который печатает только статистику: всего слов, разных слов, самое длинное слово. Запустите его через `swift run WordyStats`.
   <details><summary>Подсказка</summary>Новая папка в <code>Sources/</code>, новый <code>.executableTarget</code> в манифесте с зависимостью от <code>WordyCore</code>.</details>

---

## Урок 6. Зависимости

Сейчас топ слов выбирается полной сортировкой всех слов. Если разных слов `n`, а нужен топ из `k`, сортировка стоит O(n log n). Есть способ за O(n log k): держать **кучу** из `k` лучших элементов. Писать кучу самим не нужно, она есть в библиотеке Apple **swift-collections**. Подключим её.

Идея: кладём элементы в кучу по одному и, как только в ней стало больше k элементов, выбрасываем минимальный. В конце останутся ровно k самых больших. `Heap` из swift-collections — min-max куча, она умеет за O(log n) доставать и минимум, и максимум, так что потом топ легко выгрузить в порядке убывания.

### Подключение в два шага

Сначала объявляем пакет в `dependencies`, потом указываем таргету, какой **продукт** из этого пакета ему нужен:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Wordy",
    platforms: [.macOS(.v14)],
    dependencies: [
        // шаг 1: откуда брать пакет и какие версии допустимы
        .package(url: "https://github.com/apple/swift-collections", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: "WordyCore",
            dependencies: [
                // шаг 2: какой продукт и из какого пакета
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .executableTarget(name: "Wordy", dependencies: ["WordyCore"]),
    ]
)
```

Теперь можно добавить в библиотеку вторую реализацию топа:

```swift
// Sources/WordyCore/TopWordsHeap.swift
import Collections

/// Топ слов через кучу размера limit: O(n log k).
public func topWordsHeap(_ counts: [String: Int], limit: Int) -> [WordCount] {
    guard limit > 0 else { return [] }
    var heap = Heap<WordCount>()
    for (word, count) in counts {
        heap.insert(WordCount(word: word, count: count))
        if heap.count > limit {
            _ = heap.popMin()          // выкидываем худший из лучших
        }
    }
    var result: [WordCount] = []
    while let item = heap.popMax() {   // достаём от лучшего к худшему
        result.append(item)
    }
    return result
}
```

Переключите `main.swift` на `topWordsHeap` и выполните `swift run`. SwiftPM сам скачает зависимость.

**Частая ошибка.** В `.product(name:package:)` указываются два разных имени:

- `package:` — **идентификатор пакета**. Это последний кусок URL без `.git`. Для `https://github.com/apple/swift-collections` это `swift-collections`;
- `name:` — **имя продукта**. Оно объявлено в разделе `products` манифеста чужого пакета, обычно его называют в README.

Если ошибиться в любом из них, получите ошибку вида `product 'X' required by package ... not found`.

### Правила версий

| Запись | Что означает |
|---|---|
| `from: "1.6.0"` | от 1.6.0 до 2.0.0, не включая 2.0.0. **Обычный выбор** |
| `.upToNextMinor(from: "1.6.0")` | от 1.6.0 до 1.7.0 |
| `exact: "1.6.0"` | ровно эта версия |
| `"1.4.0"..<"1.7.0"` | произвольный диапазон |
| `branch: "main"` | последний коммит ветки (нестабильно) |
| `revision: "a1b2c3d"` | конкретный коммит |
| `path: "../MyLib"` | пакет из локальной папки |

`from:` работает так, потому что пакеты следуют семантическому версионированию: несовместимые изменения бывают только при смене мажорной (первой) цифры версии.

### Добавление командами

То же самое можно сделать, не открывая манифест:

```bash
swift package add-dependency https://github.com/apple/swift-collections --from 1.6.0
swift package add-target-dependency Collections WordyCore --package swift-collections
```

Сначала несколько раз напишите это руками: важно понимать, что именно меняется в манифесте.

### Package.resolved и где лежат зависимости

После первой сборки появится файл `Package.resolved` с **точными** версиями всех скачанных зависимостей. Благодаря ему проект соберётся одинаково на любом компьютере.

- В программах `Package.resolved` **коммитят** в git. В библиотеках обычно нет: там версии выбирает тот, кто библиотекой пользуется.
- `swift package update` обновляет зависимости до новых версий в рамках правил и переписывает файл.
- `swift package resolve` скачивает ровно то, что записано в файле.
- Исходники зависимостей лежат в `.build/checkouts/`. Их можно и полезно читать.

Искать пакеты удобно на [Swift Package Index](https://swiftpackageindex.com).

Подробнее: [swift-collections (README)](https://github.com/apple/swift-collections), [Build a Command-line Tool — раздел про зависимости](https://www.swift.org/getting-started/cli-swiftpm/)

### Практика

1. Найдите в `.build/checkouts/` исходник `Heap` и посмотрите, как устроен `popMin()`. Готово, когда вы нашли файл.
2. Подключите пакет `apple/swift-algorithms` и используйте из него метод `uniqued()`, чтобы вывести первые 10 разных слов текста в порядке появления.
   <details><summary>Подсказка</summary>Имя продукта ищите в README пакета. Обратите внимание: оно совпадает с одним из популярных слов, так что проверьте, нет ли у вас таргета с таким же именем.</details>
3. `(*)` Вынесите `WordyCore` в отдельный пакет в соседней папке и подключите его к `Wordy` через `path:`. Готово, когда `Wordy` собирается, а в самом `Wordy` не осталось кода библиотеки.

---

## Урок 7. Замеры времени

Проверим, действительно ли `topWordsHeap` быстрее `topWordsSorted`, и построим график зависимости времени от числа разных слов. Это типичная задача: сравнить две реализации и получить честные цифры.

Для замеров заведём **отдельный исполняемый таргет** `WordyBench`. Так код замеров не смешивается с основной программой.

```swift
// в targets манифеста
.executableTarget(name: "WordyBench", dependencies: ["WordyCore"]),
```

### Правило 1: только release

```bash
swift run -c release WordyBench
```

Замеры в debug ничего не говорят о реальной скорости кода: без оптимизаций соотношение между реализациями может быть совсем другим.

Ещё сильнее можно ускорить код, отключив проверки переполнения и выхода за границы массива. Но тогда ошибка в индексе вызовет непредсказуемое поведение вместо понятного падения:

```bash
swift build -c release -Xswiftc -Ounchecked
```

### Способ 1: ContinuousClock (встроен)

Это время «по настенным часам»:

```swift
let clock = ContinuousClock()
let elapsed = clock.measure {
    _ = topWordsSorted(counts, limit: 10)
}
print(elapsed)                          // например, 0.001234 seconds
let ms = elapsed / .milliseconds(1)     // Double, миллисекунды
let ns = elapsed / .nanoseconds(1)      // Double, наносекунды
```

### Способ 2: процессорное время

Процессорное время — это сколько процессор работал именно на ваш процесс. На него меньше влияют другие программы, поэтому для сравнения алгоритмов его часто предпочитают.

```swift
// Sources/WordyBench/Timing.swift
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// Процессорное время процесса в наносекундах.
func cpuTimeNs() -> UInt64 {
    var ts = timespec()
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts)
    return UInt64(ts.tv_sec) * 1_000_000_000 + UInt64(ts.tv_nsec)
}

/// Среднее время одного запуска body, в наносекундах.
func measureAverageNs(repeats: Int, _ body: () -> Void) -> Double {
    let start = cpuTimeNs()
    for _ in 0..<repeats { body() }
    return Double(cpuTimeNs() - start) / Double(repeats)
}
```

### Правило 2: быстрые операции повторяем много раз

Если операция занимает микросекунды, это сравнимо с точностью часов и с накладными расходами на сам замер. Поэтому функцию запускают N раз и делят общее время на N. Это и делает `measureAverageNs`.

### Правило 3: не дайте компилятору выкинуть код

Если результат функции нигде не используется, оптимизатор в release может удалить вызов целиком, и вы «замерите» пустоту. Результат нужно использовать, например накапливать в переменной и печатать в конце:

```swift
var sink = 0
let ns = measureAverageNs(repeats: 50) {
    sink &+= topWordsSorted(counts, limit: 10).count
}
print("sink:", sink)   // этот вывод не даёт выкинуть вычисления
```

По той же причине входные данные лучше генерировать во время выполнения, а не задавать константами: константы оптимизатор может посчитать заранее.

### Правило 4: прогрев и устойчивость

- Сделайте несколько запусков вхолостую перед замером: первые вызовы медленнее из-за кэшей и выделения памяти.
- Повторите весь замер несколько раз и возьмите **медиану**, а не одно значение.
- Закройте тяжёлые программы. Ноутбук лучше держать на зарядке.

### Собираем всё вместе: замер и CSV

```swift
// Sources/WordyBench/main.swift
import Foundation
import WordyCore

/// Словарь частот с n разными словами.
func makeCounts(distinctWords n: Int) -> [String: Int] {
    var counts: [String: Int] = [:]
    for i in 0..<n {
        counts["w\(i)"] = Int.random(in: 1...1_000)
    }
    return counts
}

let limit = 10
var sink = 0
var csv = "n,sorted_ns,heap_ns\n"

for n in stride(from: 10_000, through: 200_000, by: 10_000) {
    let counts = makeCounts(distinctWords: n)

    // прогрев
    sink &+= topWordsSorted(counts, limit: limit).count
    sink &+= topWordsHeap(counts, limit: limit).count

    let sorted = measureAverageNs(repeats: 20) {
        sink &+= topWordsSorted(counts, limit: limit).count
    }
    let heap = measureAverageNs(repeats: 20) {
        sink &+= topWordsHeap(counts, limit: limit).count
    }
    csv += "\(n),\(sorted),\(heap)\n"
    print(n, Int(sorted), Int(heap))
}

try csv.write(toFile: "results.csv", atomically: true, encoding: .utf8)
print("sink:", sink)
```

```bash
swift run -c release WordyBench
```

Файл `results.csv` появится в текущей папке терминала. Построить по нему график можно чем угодно: в pgfplots внутри LaTeX, в gnuplot, в Python с matplotlib.

### Способ 3: пакет Benchmark

Пакет `ordo-one/benchmark` берёт на себя прогрев, повторы, статистику (перцентили), сравнение с прошлыми запусками и даже подсчёт выделений памяти. Для разовых замеров он избыточен, но для регулярной работы с производительностью удобен.

```swift
// в dependencies
.package(url: "https://github.com/ordo-one/benchmark", from: "1.4.0"),

// в targets
.executableTarget(
    name: "WordyBenchmarks",
    dependencies: [
        "WordyCore",
        .product(name: "Benchmark", package: "benchmark"),
    ],
    path: "Benchmarks/WordyBenchmarks",
    plugins: [
        .plugin(name: "BenchmarkPlugin", package: "benchmark"),
    ]
),
```

```swift
// Benchmarks/WordyBenchmarks/WordyBenchmarks.swift
import Benchmark
import WordyCore

let benchmarks: @Sendable () -> Void = {
    var counts: [String: Int] = [:]
    for i in 0..<100_000 { counts["w\(i)"] = Int.random(in: 1...1_000) }
    let input = counts

    Benchmark("top-10, sort") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(topWordsSorted(input, limit: 10))
        }
    }
    Benchmark("top-10, heap") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(topWordsHeap(input, limit: 10))
        }
    }
}
```

```bash
swift package benchmark
```

`blackHole` — функция из пакета, которая «использует» значение, чтобы компилятор не выкинул вычисление (правило 3).

> Раньше этот пакет назывался `package-benchmark`, и в старых статьях вы встретите адрес `ordo-one/package-benchmark` и `package: "package-benchmark"`. Сейчас репозиторий называется `ordo-one/benchmark`, и в `.product(...)` пишется `package: "benchmark"`. Это хорошая иллюстрация того, почему важно понимать, откуда берётся идентификатор пакета.

Подробнее: [ContinuousClock (Apple)](https://developer.apple.com/documentation/swift/continuousclock), [Benchmark (README)](https://github.com/ordo-one/benchmark), [документация Benchmark](https://swiftpackageindex.com/ordo-one/benchmark/documentation/benchmark)

### Практика

1. Запустите `WordyBench` в debug и в release и сравните, во сколько раз отличаются цифры. Готово, когда у вас есть оба набора чисел.
2. Постройте график по `results.csv` любым удобным инструментом. Готово, когда на графике видно, какая реализация быстрее и как растёт разница с ростом `n`.
3. Измените `limit` на 10 000 и снова сравните реализации. Объясните результат через O(n log n) и O(n log k).
4. `(*)` Перепишите замер так, чтобы каждый вариант измерялся 5 раз и в CSV попадала медиана.
5. `(*)` Подключите пакет Benchmark и запустите `swift package benchmark`. Сравните его цифры со своими.

---

## Урок 8. Тесты

Перед тем как что-то оптимизировать и замерять, нужно убедиться, что код работает правильно. Например, что `topWordsHeap` возвращает ровно то же, что `topWordsSorted`. Для этого есть тесты. Используем современную библиотеку **Swift Testing**, она входит в Swift начиная с версии 6.

Добавьте тест-таргет в манифест:

```swift
.testTarget(name: "WordyCoreTests", dependencies: ["WordyCore"]),
```

И сам файл с тестами:

```swift
// Tests/WordyCoreTests/WordyCoreTests.swift
import Testing
@testable import WordyCore      // @testable открывает и internal-объявления

@Test func splitsAndLowercases() {
    #expect(words(in: "Hello, hello WORLD!") == ["hello", "hello", "world"])
}

@Test func countsFrequencies() {
    #expect(frequencies(of: ["a", "b", "a"]) == ["a": 2, "b": 1])
}

@Test func ordersTiesAlphabetically() {
    let top = topWordsSorted(["b": 2, "a": 2, "c": 1], limit: 2)
    #expect(top.map(\.word) == ["a", "b"])
}

// один тест, прогоняемый на нескольких входных значениях
@Test(arguments: [0, 1, 3, 10])
func heapAgreesWithSort(limit: Int) {
    let counts = ["a": 5, "b": 3, "c": 5, "d": 1, "e": 3]
    #expect(topWordsHeap(counts, limit: limit) == topWordsSorted(counts, limit: limit))
}
```

```bash
swift test                              # все тесты
swift test --filter heapAgreesWithSort  # только тесты с подходящим именем
```

Основные инструменты:

| Что | Зачем |
|---|---|
| `@Test` | помечает функцию как тест |
| `@Test(arguments: [...])` | прогоняет тест на каждом значении из списка |
| `#expect(условие)` | проверка. При провале тест отмечается проваленным, но продолжает выполняться |
| `try #require(условие)` | проверка, после провала которой тест сразу останавливается. Удобна для опционалов: `let x = try #require(optional)` |
| `#expect(throws: SomeError.self) { ... }` | проверка, что код бросает ошибку |

> Если `swift test` жалуется, что не находит модуль `Testing` или `XCTest`, скорее всего у вас стоят только Command Line Tools. Поставьте полный Xcode или toolchain через swiftly (урок 0).

Старый фреймворк **XCTest** (`import XCTest`, классы-наследники `XCTestCase`, `XCTAssertEqual`) тоже работает, причём в одном таргете вместе с Swift Testing. Вы будете встречать его в чужом коде.

Подробнее: [Swift Testing (Apple)](https://developer.apple.com/documentation/testing), [swift-testing на GitHub](https://github.com/apple/swift-testing)

### Практика

1. Напишите тест, который проверяет, что для пустого текста `words(in:)` возвращает пустой массив, а `topWordsHeap` — пустой топ.
2. Напишите тест на русский текст: `"Ёжик и ЁЖИК"` должен дать одно слово с частотой 2. Готово, когда тест проходит. Если не проходит, разберитесь почему.
3. Внесите в `topWordsHeap` ошибку (например, `popMax` вместо `popMin` в цикле) и посмотрите, какие тесты упадут и как выглядит отчёт.
4. `(*)` Напишите тест, который 100 раз генерирует случайный словарь частот и сравнивает обе реализации топа.
   <details><summary>Подсказка</summary>Генератор из урока 7 можно перенести в тесты. Сам цикл по 100 случайным словарям живёт внутри одной тестовой функции.</details>

---

## Урок 9. Аргументы, ввод и вывод, файлы

Пора сделать из `wordy` настоящую утилиту: текст должен браться из файла или из стандартного ввода, а количество слов в топе задаваться параметром.

### Вручную: CommandLine.arguments

```swift
// Sources/Wordy/main.swift
import Foundation
import WordyCore

// swift run Wordy book.txt 5
let args = CommandLine.arguments   // [путь_к_программе, "book.txt", "5"]
guard args.count == 3, let limit = Int(args[2]) else {
    FileHandle.standardError.write("Использование: wordy <файл> <сколько>\n".data(using: .utf8)!)
    exit(1)
}

let text = try String(contentsOfFile: args[1], encoding: .utf8)
for item in topWordsHeap(frequencies(of: words(in: text)), limit: limit) {
    print(item.word, item.count)
}
```

Детали, которые тут видны:

- `CommandLine.arguments[0]` — это путь к самой программе. Аргументы начинаются с индекса 1.
- Сообщения об ошибках выводят в **stderr** (`FileHandle.standardError`), а не в stdout. Тогда при перенаправлении вывода в файл (`wordy book.txt 5 > out.txt`) ошибки всё равно увидит человек.
- `exit(1)` — выход с ненулевым кодом, то есть «программа завершилась ошибкой». Его проверяют скрипты.
- Относительный путь к файлу считается от **текущей папки терминала**, а не от папки с исходниками.

### Стандартный ввод

```swift
var lines: [String] = []
while let line = readLine() {      // nil — конец ввода (Ctrl+D)
    lines.append(line)
}
let text = lines.joined(separator: "\n")
```

Так текст можно подать через конвейер: `cat book.txt | swift run Wordy`, или через перенаправление: `swift run Wordy < book.txt`.

### ArgumentParser

Разбирать аргументы вручную быстро становится неудобно: нужны необязательные параметры, флаги, значения по умолчанию, справка. Для этого есть библиотека **swift-argument-parser**.

```swift
// в dependencies
.package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),

// таргет Wordy
.executableTarget(
    name: "Wordy",
    dependencies: [
        "WordyCore",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
    ]
),
```

**Удалите `main.swift`** и создайте вместо него `WordyCommand.swift`:

```swift
// Sources/Wordy/WordyCommand.swift
import ArgumentParser
import Foundation
import WordyCore

@main
struct WordyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wordy",
        abstract: "Частотный анализ слов в тексте."
    )

    @Argument(help: "Текстовый файл. Если не указан, текст читается из stdin.")
    var file: String?

    @Option(name: .shortAndLong, help: "Сколько слов показать.")
    var top: Int = 10

    @Option(help: "Минимальная длина слова.")
    var minLength: Int = 1

    func run() throws {
        let text = try file.map { try String(contentsOfFile: $0, encoding: .utf8) }
            ?? readStdin()
        let filtered = words(in: text).filter { $0.count >= minLength }
        for item in topWordsHeap(frequencies(of: filtered), limit: top) {
            print(item.word.padding(toLength: 12, withPad: " ", startingAt: 0), item.count)
        }
    }

    private func readStdin() -> String {
        var lines: [String] = []
        while let line = readLine() { lines.append(line) }
        return lines.joined(separator: "\n")
    }
}
```

```bash
swift run Wordy book.txt --top 5 --min-length 4
swift run Wordy --help        # справка генерируется автоматически
```

Как ArgumentParser превращает код в интерфейс:

| В коде | В командной строке |
|---|---|
| `@Argument var file: String?` | позиционный аргумент, необязательный благодаря `?` |
| `@Option var minLength: Int = 1` | `--min-length 4`: имя переводится в kebab-case |
| `@Option(name: .shortAndLong) var top` | `--top 5` или `-t 5` |
| `@Flag var verbose = false` | `--verbose` |

> Тип назван `WordyCommand`, а не `Wordy`, потому что `Wordy` — это уже имя модуля. Тип с тем же именем, что и модуль, иногда приводит к запутанным ошибкам. Имя команды в справке задаёт `commandName`.

Подробнее: [swift-argument-parser (README и документация)](https://github.com/apple/swift-argument-parser)

### Практика

1. Скачайте любую книгу в формате `.txt` (например, с Project Gutenberg) и запустите на ней `wordy` в release. Готово, когда вы видите топ слов книги.
2. Добавьте флаг `--csv`, при котором вывод идёт в формате `слово,частота`. Проверьте: `wordy book.txt --csv > top.csv`.
3. Добавьте опцию `--ignore <файл>` со списком стоп-слов (по одному в строке), которые нужно исключить из подсчёта.
4. `(*)` Разбейте утилиту на подкоманды: `wordy top ...` (текущее поведение) и `wordy stats ...` (всего слов, разных слов, самое длинное).
   <details><summary>Подсказка</summary>В документации ArgumentParser поищите <code>subcommands</code> в <code>CommandConfiguration</code>.</details>

---

# Часть III. Инструменты

## Урок 10. Редактор

Автодополнение, переход к определению и подсветку ошибок для Swift даёт **sourcekit-lsp**. Он входит в toolchain и работает с любым редактором, который поддерживает протокол LSP.

- **VS Code**: официальное расширение *Swift* от swiftlang. Умеет собирать, запускать тесты и отлаживать.
- **Neovim, Emacs, Zed, Sublime и другие**: подключают sourcekit-lsp как обычный языковой сервер.

Чтобы всё работало:

1. Открывайте в редакторе **корень пакета** — папку с `Package.swift`.
2. Если подсказок нет, один раз выполните `swift build`: sourcekit-lsp нужна информация о собранных модулях.

Типичная раскладка: слева редактор, справа терминал с `swift run` или `swift test`.

Подробнее: [Getting Started with Swift in VS Code](https://www.swift.org/documentation/articles/getting-started-with-vscode-swift.html), [подключение sourcekit-lsp к другим редакторам](https://github.com/swiftlang/sourcekit-lsp/tree/main/Documentation/Editor%20Integration.md)

### Практика

1. Настройте свой редактор для работы с `Wordy`. Готово, когда переход к определению `Heap` открывает исходник из `.build/checkouts/`.
2. Нарочно сделайте опечатку в имени функции и убедитесь, что редактор подсвечивает ошибку ещё до `swift build`.

---

## Урок 11. Отладка в lldb

**lldb** — отладчик из toolchain. Он позволяет остановить программу на нужной строке и посмотреть значения переменных. Отлаживают debug-сборку: в ней сохранена информация, которая связывает машинный код со строками исходника.

```bash
swift build
lldb .build/debug/Wordy
```

```
(lldb) b TopWordsHeap.swift:12        # точка останова: файл:строка
(lldb) b topWordsHeap                 # или по имени функции
(lldb) r book.txt --top 3             # запуск с аргументами
(lldb) n                              # следующая строка (next)
(lldb) s                              # войти в вызываемую функцию (step)
(lldb) c                              # продолжить до следующей точки останова
(lldb) p heap.count                   # вычислить и вывести выражение
(lldb) v                              # все локальные переменные
(lldb) bt                             # стек вызовов
(lldb) br list                        # список точек останова
(lldb) q                              # выход
```

**Условная точка останова** срабатывает, только когда выполнено условие:

```
(lldb) br set -f TopWordsHeap.swift -l 12 -c 'count > 500'
```

В VS Code с расширением Swift всё это делается мышкой: точка останова ставится кликом слева от номера строки, запуск — F5.

Часто хватает и `print`. Для подробного вывода структур есть `dump(value)`.

Подробнее: [LLDB Tutorial](https://lldb.llvm.org/tutorial.html)

### Практика

1. Поставьте точку останова внутрь цикла в `topWordsHeap` и пройдите несколько итераций, следя за `heap.count`. Готово, когда вы видели момент, где срабатывает `popMin`.
2. Поставьте условную точку останова, которая сработает на слове `"swift"` (или на любом слове из вашей книги).
3. `(*)` Попробуйте отладить release-сборку. Что не так с переменными и шагами? Объясните почему.

---

## Урок 12. Ресурсы, форматирование, когда всё сломалось

### Ресурсы

Иногда пакету нужны файлы с данными. Встроим в `WordyCore` стандартный список стоп-слов английского языка: `the`, `and`, `of` и так далее.

```
Sources/WordyCore/
├── WordyCore.swift
├── TopWordsHeap.swift
└── Resources/
    └── stopwords.txt
```

```swift
// в манифесте
.target(
    name: "WordyCore",
    dependencies: [.product(name: "Collections", package: "swift-collections")],
    resources: [.process("Resources")]
),
```

```swift
// Sources/WordyCore/StopWords.swift
import Foundation

public func defaultStopWords() -> Set<String> {
    guard let url = Bundle.module.url(forResource: "stopwords", withExtension: "txt"),
          let text = try? String(contentsOf: url, encoding: .utf8)
    else { return [] }
    return Set(words(in: text))
}
```

`Bundle.module` — это автоматически сгенерированный доступ к ресурсам **текущего** модуля. Он появляется, только если у таргета объявлены `resources`.

| Правило | Что делает с файлами |
|---|---|
| `.process("Resources")` | может обрабатывать файлы (оптимизировать картинки и т. п.), структура папок не сохраняется |
| `.copy("Resources")` | копирует как есть, вместе с папкой |

### Форматирование

Начиная со Swift 6, форматтер входит в toolchain:

```bash
swift format --in-place --recursive Sources Tests   # отформатировать
swift format lint --recursive Sources               # только проверить стиль
swift format dump-configuration > .swift-format     # сохранить настройки, чтобы их менять
```

Настройки ищутся в файле `.swift-format` в папке с исходником или выше.

### Когда всё сломалось

Пробуйте по порядку, от лёгкого к радикальному:

```bash
swift package clean          # 1. пересобрать с нуля
swift package reset          # 2. удалить .build целиком
swift package resolve        # 3. заново скачать зависимости
swift package purge-cache    # 4. очистить глобальный кэш SwiftPM
swift build -v               # подробный лог, чтобы понять, что происходит
```

Частые ошибки:

| Сообщение | Причина |
|---|---|
| `product 'X' required by package ... not found` | неверное `name:` или `package:` в `.product(...)` (урок 6) |
| `cannot find 'foo' in scope` | функция не `public` или не `package`, либо нет `import` или зависимости таргета (урок 5) |
| `'main' attribute cannot be used in a module that contains top-level code` | в таргете есть и `main.swift`, и `@main` (уроки 3, 9) |
| `'X' initializer is inaccessible due to 'internal' protection level` | у `public struct` нет `public init` (урок 5) |
| `target 'X' has overlapping sources` | папки двух таргетов пересекаются |
| ошибки про `Sendable` и конкурентность | строгий режим Swift 6. Для простых учебных пакетов можно поставить `swift-tools-version: 5.10` |

Подробнее: [swift-format (README)](https://github.com/swiftlang/swift-format)

### Практика

1. Добавьте стоп-слова в ресурсы, а в `wordy` — флаг `--keep-stop-words`. По умолчанию стоп-слова исключаются, с флагом остаются. Готово, когда топ книги без флага состоит из «содержательных» слов.
2. Отформатируйте весь проект через `swift format` и посмотрите в `git diff`, что изменилось.
3. Воспроизведите по очереди три ошибки из таблицы выше и почините их.

---

# Итог: проект целиком

```
Wordy/
├── Package.swift
├── Package.resolved
├── Sources/
│   ├── WordyCore/                 ← библиотека: вся логика
│   │   ├── WordyCore.swift
│   │   ├── TopWordsHeap.swift
│   │   ├── StopWords.swift
│   │   └── Resources/stopwords.txt
│   ├── Wordy/                     ← CLI на ArgumentParser
│   │   └── WordyCommand.swift
│   └── WordyBench/                ← ручные замеры, пишет results.csv
│       ├── main.swift
│       └── Timing.swift
├── Benchmarks/
│   └── WordyBenchmarks/           ← (опционально) пакет Benchmark
└── Tests/
    └── WordyCoreTests/
        └── WordyCoreTests.swift
```

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Wordy",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "WordyCore",
            dependencies: [.product(name: "Collections", package: "swift-collections")],
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "Wordy",
            dependencies: [
                "WordyCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(name: "WordyBench", dependencies: ["WordyCore"]),
        .testTarget(name: "WordyCoreTests", dependencies: ["WordyCore"]),
    ]
)
```

Рабочий цикл:

```bash
swift test                                  # логика корректна?
swift run Wordy book.txt --top 10           # пробный запуск
swift run -c release WordyBench             # замеры
swift build -c release                      # итоговый бинарник: .build/release/Wordy
```

---

# Финальное задание

Напишите с нуля утилиту **`dupfind`**, которая ищет одинаковые файлы в папке. Она должна задействовать почти всё, что было в курсе.

Требования:

- Пакет из библиотеки `DupfindCore` и исполняемого таргета `dupfind`.
- Интерфейс на ArgumentParser: `dupfind <папка> [--min-size <байты>] [--json]`.
- Обход папки рекурсивно через `FileManager`. Группы одинаковых файлов выводятся вместе, с размером группы.
- Содержимое файлов сравнивается по хешу SHA-256 из пакета `apple/swift-crypto`. Нужные имя продукта и актуальную версию найдите в README сами.
- Две стратегии поиска:
  - (А) посчитать хеш каждого файла;
  - (Б) сначала сгруппировать файлы по размеру и считать хеш только для файлов, у которых размер совпал.
- Тесты: создайте во временной папке набор файлов с известными дубликатами и проверьте, что обе стратегии находят одни и те же группы.
- Отдельный таргет с замером обеих стратегий на папке с тысячами файлов (release, повторы, медиана) и выводом результатов в CSV.
- Ошибки (папка не существует, нет прав на файл) выводятся в stderr. Программа при этом не падает и завершается с ненулевым кодом, если что-то пошло не так.

---

# Шпаргалка

```bash
# без пакета
swift file.swift               swiftc -O file.swift -o app

# создание
swift package init --name X --type executable   # / library / tool / empty

# сборка, запуск, тесты
swift build                    swift build -c release
swift run [таргет] [аргументы]  swift run -c release [таргет]
swift test [--filter Имя]

# зависимости
swift package add-dependency <url> --from 1.0.0
swift package add-target-dependency <Продукт> <Таргет> --package <пакет>
swift package resolve          swift package update
swift package show-dependencies

# обслуживание
swift package clean            swift package reset
swift package describe         swift build --show-bin-path
swift format --in-place --recursive Sources Tests

# отладка
lldb .build/debug/X   →   b файл:строка | r аргументы | n | s | c | p выражение | v | bt
```

```swift
// зависимость
dependencies: [
    .package(url: "https://github.com/OWNER/REPO", from: "1.0.0"),
],
targets: [
    .executableTarget(name: "App", dependencies: [
        "MyLib",                                            // таргет этого пакета
        .product(name: "ProductName", package: "REPO"),     // продукт чужого пакета
    ]),
]

// замер
let elapsed = ContinuousClock().measure { work() }
let ms = elapsed / .milliseconds(1)

// тест
@Test(arguments: [1, 2, 3]) func check(x: Int) { #expect(f(x) > 0) }
```

---

# Источники и что почитать дальше

**Официальная документация**

- [Build a Command-line Tool](https://www.swift.org/getting-started/cli-swiftpm/) — короткое официальное руководство: пакет, зависимость, ArgumentParser.
- [Swift Package Manager](https://www.swift.org/documentation/package-manager/) — полная документация SwiftPM: команды, манифест, ресурсы, плагины.
- [PackageDescription](https://developer.apple.com/documentation/packagedescription) — справочник по всему, что можно написать в `Package.swift`.
- [Access Control](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol/) — глава книги The Swift Programming Language про уровни доступа.
- [Swift Testing](https://developer.apple.com/documentation/testing) — документация фреймворка тестирования, включая переход с XCTest.
- [ContinuousClock](https://developer.apple.com/documentation/swift/continuousclock) — часы и тип `Duration` для замеров.
- [Getting Started with Swiftly on macOS](https://swift.org/install/macos/swiftly/) — установка и переключение версий Swift.
- [Getting Started with Swift in VS Code](https://www.swift.org/documentation/articles/getting-started-with-vscode-swift.html) — настройка VS Code.
- [Editor Integration (sourcekit-lsp)](https://github.com/swiftlang/sourcekit-lsp/tree/main/Documentation/Editor%20Integration.md) — подключение языкового сервера к другим редакторам.
- [LLDB Tutorial](https://lldb.llvm.org/tutorial.html) — основы работы с отладчиком.

**Библиотеки из курса**

- [swift-collections](https://github.com/apple/swift-collections) — `Heap`, `Deque`, `OrderedDictionary` и другие структуры данных.
- [swift-argument-parser](https://github.com/apple/swift-argument-parser) — разбор аргументов командной строки, подкоманды, автодополнение в shell.
- [Benchmark](https://github.com/ordo-one/benchmark) и [его документация](https://swiftpackageindex.com/ordo-one/benchmark/documentation/benchmark) — бенчмарки со статистикой и сравнением с прошлыми запусками.
- [swift-format](https://github.com/swiftlang/swift-format) — форматтер и линтер, описание настроек.

**Статьи и справочники**

- [The Missing SPM Syntax Cheatsheet](https://swifttoolkit.dev/posts/spm-cheatsheet) — шпаргалка по синтаксису манифеста с примерами на каждый случай.
- [Swift Package Index](https://swiftpackageindex.com) — поиск пакетов, их документация и совместимость с версиями Swift.
