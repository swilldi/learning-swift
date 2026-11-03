# macOS-приложение на SwiftUI

Курс о том, как с нуля написать настоящее приложение для macOS на Swift и SwiftUI и по ходу разобраться в объектно-ориентированном проектировании. После него вы будете уверенно собирать интерфейс на SwiftUI, раскладывать код по слоям (MVVM), отделять логику от интерфейса и покрывать её тестами, а ещё узнавать и применять десяток классических паттернов там, где они действительно нужны.

**Как проходить.** Идите по порядку и весь код набирайте руками, а не копируйте. Каждый урок заканчивается разделами «Готово, когда» и «Практика». Задания необязательны для продолжения, но именно на них материал и усваивается. Чем дальше, тем меньше готового кода: в первых уроках он дан целиком, в середине вы получаете интерфейс типа и тесты, а реализацию пишете сами, в конце — в основном требования и подсказки. Если застряли, это нормально: так и задумано.

**Наставник.** В проекте настроен агент, который **не пишет код за вас**: запись в `.swift`-файлы для него заблокирована. Зато он собирает проект, гоняет тесты, объясняет ошибки, делает ревью и даёт подсказки по уровням. Как им пользоваться, описано в уроке 0.

**Сквозной проект: Focusly.** Приложение для работы по технике помидора: список задач, таймер «25 минут фокуса, 5 минут отдыха», статистика по дням и таймер в строке меню. Каждый урок добавляет в него одну возможность и один-два паттерна.

```
┌ Focusly ──────────────────────────────────────────────────────────────┐
│ ☰ Все        │ [Новая задача        ] [+]  │  Задача                  │
│ ○ Активные   │ ○ Написать отчёт     1/3 🍅 │  Название: Написать отчёт│
│ ✓ Готово     │ ○ Прочитать главу    0/2 🍅 │  Оценка: 3 🍅            │
│              │ ● Разобрать почту    1/1 🍅 │        Фокус             │
│ 📊 Статистика │                             │        18:42             │
│              │                             │  [⏸ Пауза] [↺] [⏭]       │
└───────────────────────────────────────────────────────────────────────┘
                                                        строка меню: 18:42
```

**Что нужно знать заранее.** Базовый Swift (типы, опционалы, замыкания, `struct`/`class`, протоколы на уровне «знаю, что это») и SwiftPM на уровне курса «Swift в консоли» (`../cli/swift-cli-guide.md`): что такое пакет, таргет, модуль, `swift test`. Остальное объясняется по ходу.

**Паттерны.** Каждый паттерн появляется тогда, когда без него становится неудобно, и выделен врезкой:

> **🧩 Паттерн: Название.** Какую проблему решает, как устроен, где в Focusly.

Полная таблица «паттерн → где в проекте → какую проблему решает» есть в [итоге](#итог-проект-целиком).

**Содержание**

- Часть I. Основы
  - [Урок 0. Окружение и наставник](#урок-0-окружение-и-наставник)
  - [Урок 1. Анатомия SwiftUI-приложения](#урок-1-анатомия-swiftui-приложения)
  - [Урок 2. Модель: структуры, инкапсуляция, тесты](#урок-2-модель-структуры-инкапсуляция-тесты)
  - [Урок 3. Состояние: @State, @Binding, списки](#урок-3-состояние-state-binding-списки)
  - [Урок 4. MVVM и Observer](#урок-4-mvvm-и-observer)
- Часть II. Архитектура
  - [Урок 5. Протоколы и Repository](#урок-5-протоколы-и-repository)
  - [Урок 6. Файлы, JSON и обобщённое хранилище](#урок-6-файлы-json-и-обобщённое-хранилище)
  - [Урок 7. Внедрение зависимостей и Composition Root](#урок-7-внедрение-зависимостей-и-composition-root)
  - [Урок 8. Навигация macOS и Strategy](#урок-8-навигация-macos-и-strategy)
  - [Урок 9. Таймер: конечный автомат, Delegate, конкурентность](#урок-9-таймер-конечный-автомат-delegate-конкурентность)
- Часть III. Возможности macOS
  - [Урок 10. Command, отмена действий и меню](#урок-10-command-отмена-действий-и-меню)
  - [Урок 11. Decorator и Adapter: логи и уведомления](#урок-11-decorator-и-adapter-логи-и-уведомления)
  - [Урок 12. Статистика: Charts, Template Method, окна](#урок-12-статистика-charts-template-method-окна)
  - [Урок 13. Строка меню, настройки, отладка](#урок-13-строка-меню-настройки-отладка)
- [Итог: проект целиком](#итог-проект-целиком)
- [Финальное задание](#финальное-задание)
- [Шпаргалка](#шпаргалка)
- [Источники и что почитать дальше](#источники-и-что-почитать-дальше)

---

# Часть I. Основы

## Урок 0. Окружение и наставник

Создадим в Xcode проект: приложение плюс отдельный Swift-пакет с логикой. И разберёмся, как работать с агентом-наставником.

### Что уже лежит в папке

```
vspomnit/
├── CLAUDE.md               правила для агента (наставник, а не исполнитель)
├── docs/
│   ├── macos-swiftui-guide.md   эта методичка
│   └── PROGRESS.md              чек-лист прогресса по урокам
├── scripts/
│   ├── check.sh            проверка: стиль + сборка + тесты
│   └── run.sh              собрать и запустить приложение
├── .swift-format           настройки стиля кода
└── .claude/                скиллы и хук агента
```

Кода пока нет ни строчки: и приложение, и пакет вы создадите сами. Проверьте инструменты:

```bash
xcodebuild -version     # Xcode 26 или новее
swift --version         # Swift 6.2 или новее
```

### Зачем два проекта

Приложение состоит из двух частей:

| Часть | Что внутри | Чем проверяется |
|---|---|---|
| `FocuslyCore` (Swift-пакет) | модели, ViewModel'и, хранилища, таймер — всё, что можно проверить без экрана | `swift test` за секунды |
| `Focusly` (Xcode-проект) | `App`, окна, SwiftUI-представления, иконка, настройки песочницы | запуск приложения |

> **🧩 Паттерн: Слоистая архитектура.** Код делится на слои, и зависимости идут в одну сторону: интерфейс знает о логике, логика об интерфейсе — нет. Отдельный пакет делает это правило **физическим**: из `FocuslyCore` нельзя случайно сделать `import SwiftUI` и завязать логику на кнопки, а наружу видно только то, что помечено `public`. Бонус: тесты ядра не запускают приложение и работают мгновенно.

### Создаём Xcode-проект

1. Xcode → **File → New → Project…** → вкладка **macOS** → **App** → Next.
2. Заполните:
   - **Product Name:** `Focusly`
   - **Team:** None (для локального запуска подпись не нужна)
   - **Organization Identifier:** `com.<ваше-имя>` (получится bundle id `com.<ваше-имя>.Focusly`)
   - **Interface:** SwiftUI, **Language:** Swift
   - **Testing System:** None (логику тестируем в пакете)
   - **Storage:** None
3. Next → выберите папку `vspomnit` → **снимите** галочку «Create Git repository on my Mac» (репозиторий уже есть) → Create.

Xcode создаст `vspomnit/Focusly/Focusly.xcodeproj` и папку с исходниками `vspomnit/Focusly/Focusly/`. Именно этот путь ждёт `scripts/check.sh`.

> Если вы назвали проект иначе или положили в другое место, скрипты не найдут его. Можно переименовать папку или запускать так: `FOCUSLY_PROJECT=путь/к/Проект.xcodeproj FOCUSLY_SCHEME=Схема ./scripts/check.sh`.

### Создаём пакет ядра

Не закрывая проект `Focusly`:

1. **File → New → Package…** → шаблон **Library** → Next.
2. Имя: `FocuslyCore`. Если Xcode спросит про систему тестов, выберите **Swift Testing**.
3. В окне сохранения:
   - папка — снова `vspomnit` (пакет должен лечь **рядом** с папкой `Focusly`, а не внутрь неё);
   - **Add to:** `Focusly` — так пакет сразу появится в навигаторе проекта;
   - галочку Git снова снимите.
4. Create.

Должно получиться:

```
vspomnit/
├── Focusly/
│   ├── Focusly.xcodeproj
│   └── Focusly/              исходники приложения
└── FocuslyCore/
    ├── Package.swift
    ├── Sources/FocuslyCore/FocuslyCore.swift
    └── Tests/FocuslyCoreTests/FocuslyCoreTests.swift
```

> Если в окне сохранения нет поля **Add to**, создайте пакет как есть, а потом перетащите папку `FocuslyCore` из Finder в навигатор проекта `Focusly`.

**Поправьте `Package.swift`.** Шаблон Xcode не указывает платформу, и тогда пакет собирается под очень старую macOS, где нет `@Observable` (урок 4). Откройте `FocuslyCore/Package.swift` и добавьте строку `platforms`. Сверьтесь с образцом:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FocuslyCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "FocuslyCore", targets: ["FocuslyCore"]),
    ],
    targets: [
        .target(name: "FocuslyCore"),
        .testTarget(name: "FocuslyCoreTests", dependencies: ["FocuslyCore"]),
    ]
)
```

Версия в первой строке у вас может быть новее (`6.2`, `6.3`…) — это нормально. Если в шаблоне есть дополнительные настройки вроде `swiftSettings`, пока уберите их: методичка рассчитана на пакет без них.

> Это ровно то, что вы делали в курсе «Swift в консоли» командой `swift package init --type library`, только через Xcode. Пакет остаётся обычным SwiftPM-пакетом: в терминале работают `swift build` и `swift test`.

### Подключаем пакет к приложению

То, что пакет виден в навигаторе, ещё не значит, что приложение может его импортировать. Нужно явно связать библиотеку с таргетом:

1. Выделите проект **Focusly** в навигаторе → таргет **Focusly** → вкладка **General**.
2. Раздел **Frameworks, Libraries, and Embedded Content** → «+» → выберите **FocuslyCore** (библиотека из пакета) → Add.

Проверьте связь: в `ContentView.swift` добавьте наверх `import FocuslyCore` и соберите (**⌘B**). Ошибки «No such module» быть не должно. Затем строку можно убрать.

Запустите приложение: **⌘R**. Должно открыться окно с глобусом и «Hello, world!». Затем в терминале:

```bash
./scripts/check.sh
```

Все четыре строки итога должны быть зелёными (`✔`). Первая сборка приложения займёт около минуты, дальше быстрее.

> **Нужно знать: изоляция по умолчанию.** Новые проекты Xcode включают для таргета приложения настройку **Default Actor Isolation = MainActor**: весь код приложения по умолчанию выполняется на главном потоке, и компилятор не ругается на конкурентность там, где её нет. В пакете `FocuslyCore` этой настройки нет, поэтому классы, которые работают с интерфейсом, мы будем помечать `@MainActor` явно (подробно в уроке 4).

### Как работать с наставником

Откройте Claude Code в папке `vspomnit`. Агент прочитает `CLAUDE.md` и будет работать наставником. Основные команды:

| Команда | Что делает |
|---|---|
| `/lesson` | Где я, что готово в текущем уроке, что дальше. Отмечает пункты в `docs/PROGRESS.md` |
| `/check` | Запускает `scripts/check.sh` и объясняет ошибки человеческим языком, не исправляя их |
| `/hint что не получается` | Подсказка. Первый раз — наводящая, по просьбе «ещё» — конкретнее, но без готового кода |
| `/mentor-review` | Ревью незакоммиченных изменений: баги, паттерн урока, ООП, идиомы, тесты |
| `/explain что-то` | Объяснение понятия или паттерна на примере из другой области |

Можно и просто писать обычным текстом: «почему тут ошибка?», «нормально ли я сделал Repository?».

> Агент не может писать в `.swift`-файлы проекта: это блокирует хук `.claude/hooks/guard-swift-code.sh`. Если когда-нибудь действительно захотите, чтобы он что-то написал (например, скучный шаблонный код), выключите режим: `touch .claude/mentor-off`, а потом включите обратно: `rm .claude/mentor-off`.

**Ритм урока:** читаете → набираете код → `./scripts/check.sh` → смотрите в приложении → `/mentor-review` → практика → коммит.

```bash
git add -A && git commit -m "урок 0: проект и пакет"
```

Подробнее: [Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

### Готово, когда

- приложение запускается по ⌘R;
- пакет `FocuslyCore` лежит рядом с `Focusly`, в `Package.swift` указано `.macOS(.v15)`;
- в таргете `Focusly` подключена библиотека `FocuslyCore`;
- `./scripts/check.sh` полностью зелёный.

### Практика

1. Сломайте тест из шаблона в `FocuslyCoreTests.swift` (например, добавьте `#expect(1 + 1 == 3)`) и запустите `./scripts/check.sh core`. Посмотрите, как выглядит упавший тест, затем попросите агента `/check` объяснить вывод. Почините. Готово, когда вы понимаете, какая строка вывода указывает на место падения.
2. Найдите в настройках таргета **Focusly → Build Settings** параметры `Default Actor Isolation`, `Swift Language Version` и `macOS Deployment Target`. Готово, когда вы можете назвать их значения.
   <details><summary>Подсказка</summary>В Build Settings есть строка поиска справа вверху; переключатель «All / Basic» должен стоять на All.</details>

---

## Урок 1. Анатомия SwiftUI-приложения

Разберём, из чего состоит SwiftUI-приложение и как устроен декларативный интерфейс. Сделаем приветственный экран.

### Точка входа

Откройте `Focusly/Focusly/FocuslyApp.swift`:

```swift
import SwiftUI

@main
struct FocuslyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

| Элемент | Что это |
|---|---|
| `@main` | точка входа: отсюда стартует программа (вместо `main.swift` из консольных утилит) |
| `App` | протокол приложения; его `body` описывает **сцены** |
| `Scene` | что-то, что система показывает: окно, окно настроек, значок в строке меню |
| `WindowGroup` | сцена «обычное окно»; на macOS по ⌘N можно открыть ещё одно такое же |
| `ContentView()` | корневое представление (View) окна |

### View — это описание, а не объект на экране

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "timer")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Focusly")
                .font(.largeTitle.bold())
            Text("Фокус на одной задаче за раз")
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .frame(minWidth: 480, minHeight: 320)
    }
}

#Preview {
    ContentView()
}
```

Что здесь важно:

- `View` — протокол с одним требованием: свойство `body`. View — это **структура**, лёгкое описание «что должно быть на экране». SwiftUI создаёт и выбрасывает такие структуры постоянно, а настоящие элементы окна строит и обновляет сам.
- `some View` — **непрозрачный тип**: «здесь конкретный тип View, но какой именно — не твоё дело». Реальный тип у `VStack` с тремя элементами внутри громоздкий, и писать его руками не нужно.
- `VStack`, `HStack`, `ZStack` — стопки по вертикали, горизонтали и в глубину. `Spacer()` занимает всё свободное место.
- `.font(...)`, `.padding(...)` — **модификаторы**. Каждый возвращает новую View, обёрнутую вокруг старой.
- `Image(systemName:)` — значки SF Symbols. Каталог значков — приложение SF Symbols от Apple.
- `#Preview` — живой предпросмотр справа от кода (**⌥⌘↩** показать/скрыть canvas). Приложение для этого запускать не нужно.

> Порядок модификаторов важен: каждый оборачивает результат предыдущего. `Text("A").padding().background(.yellow)` даст жёлтый прямоугольник с отступами, а `Text("A").background(.yellow).padding()` — жёлтый фон только под буквой и прозрачный отступ вокруг.

### Декларативно, а не императивно

| AppKit (императивно) | SwiftUI (декларативно) |
|---|---|
| создать `NSTextField`, добавить в окно, при изменении данных найти его и поменять `stringValue` | описать `Text(title)`; когда `title` изменится, SwiftUI сам перерисует нужное |
| интерфейс хранит состояние сам | интерфейс — функция от состояния: `UI = f(state)` |

Это главная мысль SwiftUI, и следующие уроки на ней построены: мы будем менять **данные**, а не элементы окна.

### Свои компоненты

Большой `body` разбивают на маленькие View с параметрами:

```swift
struct FeatureRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
```

Используется как обычная View: `FeatureRow(title: "Задачи", systemImage: "checklist")`.

> **🧩 Паттерн: Composite (Компоновщик).** Объекты складываются в дерево, и с листом и с веткой работают одинаково. В SwiftUI всё — View: и `Text`, и `VStack` с десятком детей внутри, и ваш `FeatureRow`. Поэтому любой компонент можно вложить куда угодно.
>
> **И немного Builder.** Содержимое `VStack { ... }` — это не массив, а замыкание, помеченное `@ViewBuilder` (частный случай *result builder*). Компилятор превращает перечисленные строки в одно значение-дерево. Поэтому внутри можно писать `if` и `ForEach`, но нельзя `let x = 5; print(x)` как в обычной функции.

Подробнее: [App organization](https://developer.apple.com/documentation/swiftui/app-organization), [Previews in Xcode](https://developer.apple.com/documentation/swiftui/previews-in-xcode)

### Готово, когда

- в окне показан приветственный экран вместо «Hello, world!»;
- есть хотя бы один свой компонент с параметрами и для него свой `#Preview`.

### Практика

1. Сделайте приветственный экран: значок, заголовок, подзаголовок и три строки возможностей через `FeatureRow` («Задачи», «Таймер», «Статистика» с подходящими SF Symbols). Готово, когда превью и запущенное приложение выглядят одинаково.
2. Сделайте компонент `Badge(text:)` — текст в цветной «таблетке» (отступы, фон, скруглённые края). Затем поменяйте местами `.padding()` и `.background()` и объясните, что произошло. Готово, когда в превью видны оба варианта.
   <details><summary>Подсказка</summary>Скругление — <code>.clipShape(.capsule)</code> или <code>.background(.blue, in: .capsule)</code>.</details>
3. (*) Задайте окну размер по умолчанию 900×600 через модификатор у `WindowGroup`, а у `ContentView` — минимальный размер. Готово, когда новое окно (⌘N) открывается нужного размера и не сжимается меньше минимума.
   <details><summary>Подсказка</summary>Посмотрите <code>.defaultSize(width:height:)</code> у сцены.</details>

---

## Урок 2. Модель: структуры, инкапсуляция, тесты

Создадим первую модель — задачу — в пакете ядра и покроем её тестами. Заодно разберёмся, почему модели в Swift обычно структуры и как защищать данные от некорректных изменений.

Удалите файл из шаблона `FocuslyCore/Sources/FocuslyCore/FocuslyCore.swift` и создайте рядом `FocusTask.swift`. Файлы пакета можно редактировать прямо в Xcode: пакет виден в навигаторе проекта.

```swift
import Foundation

public struct FocusTask: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var isDone: Bool
    public let createdAt: Date
    public var estimate: Int                        // сколько «помидоров» планируем
    public private(set) var completedPomodoros: Int // сколько уже сделали

    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isDone: Bool = false,
        createdAt: Date = .now,
        estimate: Int = 1
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.notes = notes
        self.isDone = isDone
        self.createdAt = createdAt
        self.estimate = max(1, estimate)
        self.completedPomodoros = 0
    }

    public var progress: Double {
        min(1, Double(completedPomodoros) / Double(estimate))
    }

    public mutating func registerPomodoro() {
        completedPomodoros += 1
    }
}
```

Разберём решения по строкам.

**`public` везде.** Пакет — отдельный модуль. По умолчанию всё в нём `internal`, то есть невидимо для приложения. Для структуры компилятор сам создаёт поэлементный `init`, но он всегда `internal`, поэтому публичный `init` приходится писать руками.

| Уровень | Кому виден |
|---|---|
| `private` | только внутри объявления (и его расширений в том же файле) |
| `fileprivate` | в пределах файла |
| `internal` (по умолчанию) | во всём модуле |
| `public` | другим модулям (можно использовать, но не наследовать класс) |
| `open` | другим модулям, плюс можно наследовать и переопределять |

**`let id`, `let createdAt`.** Идентификатор и дата создания не должны меняться никогда, и `let` гарантирует это на уровне компилятора.

**`private(set) var completedPomodoros`.** Читать можно всем, а менять только изнутри типа. Снаружи число помидоров меняется единственным способом: `registerPomodoro()`. Нельзя случайно написать `task.completedPomodoros = -5`.

**`init` чинит входные данные:** обрезает пробелы у названия и не даёт оценке быть меньше 1. Благодаря этому `progress` никогда не делит на ноль.

> **🧩 ООП: Инкапсуляция и инварианты.** Инвариант — условие, которое верно для объекта всегда: «оценка ≥ 1», «помидоры не убывают». Инкапсуляция — способ сделать так, чтобы нарушить инвариант было **невозможно**, а не просто «не принято». Инструменты в Swift: `let`, `private(set)`, проверки в `init`, `mutating`-методы вместо прямой записи в поля. Хорошее правило: делайте всё максимально закрытым и открывайте только по необходимости.

**Протоколы в заголовке:**

| Протокол | Зачем | Где понадобится |
|---|---|---|
| `Identifiable` | у значения есть `id`, по нему SwiftUI отличает строки списка | урок 3 |
| `Hashable` | можно класть в `Set` и использовать как выделение в списке | уроки 3, 8 |
| `Codable` | можно сохранить в JSON и прочитать обратно | урок 6 |
| `Sendable` | значение безопасно передавать между потоками | урок 9 |

Все четыре компилятор реализует сам, потому что все поля структуры уже им соответствуют.

### Почему структура, а не класс

```swift
var a = FocusTask(title: "A")
var b = a          // копия
b.title = "B"
print(a.title)     // "A": у структур семантика значения
```

С классом `b = a` скопировал бы **ссылку**, и `a.title` тоже стал бы `"B"`. Для данных это почти всегда ловушка: кто-то где-то поменял объект, и он изменился везде.

| | `struct` | `class` |
|---|---|---|
| присваивание | копирует значение | копирует ссылку на тот же объект |
| изменение | только через `var` и `mutating` | через любую ссылку |
| наследование | нет (только протоколы) | есть |
| идентичность («тот же самый объект») | нет | есть (`===`) |
| для чего | данные, модели | объекты с жизненным циклом и общим состоянием: ViewModel, сервисы |

> **🧩 Паттерн: Value Object (Объект-значение).** Объект, который определяется своими данными, а не «личностью». Два `FocusTask` с одинаковыми полями равны (`==`), и копировать их безопасно. В Swift это естественно получается из `struct` + `Hashable`. Классы мы будем использовать для того, у чего *есть* личность и жизненный цикл, — для ViewModel в уроке 4.

### Тесты на Swift Testing

Удалите тест из шаблона `FocuslyCoreTests.swift` и создайте `FocuslyCore/Tests/FocuslyCoreTests/FocusTaskTests.swift`:

```swift
import Foundation
import Testing
@testable import FocuslyCore

@Suite("FocusTask")
struct FocusTaskTests {
    @Test func titleIsTrimmed() {
        let task = FocusTask(title: "  Купить молоко \n")
        #expect(task.title == "Купить молоко")
    }

    @Test func progressGrowsWithPomodoros() {
        var task = FocusTask(title: "Отчёт", estimate: 4)
        #expect(task.progress == 0)
        task.registerPomodoro()
        task.registerPomodoro()
        #expect(task.progress == 0.5)
    }

    @Test func structIsCopiedOnAssignment() {
        let original = FocusTask(title: "A")
        var copy = original
        copy.title = "B"
        #expect(original.title == "A")
    }
}
```

| Конструкция | Смысл |
|---|---|
| `@Test` | функция — тест. Имя функции становится именем теста |
| `@Suite("…")` | группа тестов с человекочитаемым именем (необязательно) |
| `#expect(условие)` | проверка; если ложь, тест помечается упавшим, но выполняется дальше. В отчёте видны значения обеих сторон |
| `#require(условие)` | проверка, после провала которой тест останавливается. Для опционалов: `let x = try #require(optional)` |
| `@testable import` | открывает тестам `internal`-объявления модуля |

```bash
./scripts/check.sh core
./scripts/check.sh test FocusTask   # только тесты, в имени которых есть FocusTask
```

> Тест на копирование структуры проверяет не ваш код, а язык. В реальном проекте такой тест лишний; здесь он для того, чтобы один раз увидеть семантику значения своими глазами.

Подробнее: [Structures and Classes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/), [Access Control](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/accesscontrol/), [Swift Testing](https://developer.apple.com/documentation/testing)

### Готово, когда

- `FocusTask` лежит в ядре, все его поля и `init` публичные;
- тесты `FocusTask` проходят в `./scripts/check.sh core`.

### Практика

1. Напишите тест, что оценка `0` или `-3` превращается в `1`, и тест, что `progress` не превышает `1`, даже если помидоров больше оценки. Готово, когда оба теста зелёные.
2. Добавьте в `FocusTask` вычисляемое свойство `isOverEstimate` (помидоров сделано больше, чем планировали) и тесты к нему. Готово, когда тесты покрывают случаи «меньше», «ровно» и «больше».
3. (*) Попробуйте в тесте написать `task.completedPomodoros = 10`. Прочитайте ошибку компилятора. Затем уберите `@testable` из импорта и посмотрите, что ещё перестанет компилироваться и почему. Верните как было. Готово, когда вы можете объяснить разницу между `private(set)`, `internal` и `public`.

---

## Урок 3. Состояние: @State, @Binding, списки

Сделаем первую рабочую версию списка задач — пока целиком внутри View. Посмотрим, как SwiftUI хранит состояние, и почему так долго жить нельзя.

Создайте в приложении файл `TaskListDraftView.swift`:

```swift
import FocuslyCore
import SwiftUI

struct TaskListDraftView: View {
    @State private var tasks: [FocusTask] = []
    @State private var newTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Новая задача", text: $newTitle)
                    .onSubmit(addTask)
                Button("Добавить", systemImage: "plus", action: addTask)
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(8)

            List($tasks) { $task in
                Toggle(task.title, isOn: $task.isDone)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func addTask() {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        tasks.append(FocusTask(title: title))
        newTitle = ""
    }
}

#Preview {
    TaskListDraftView()
}
```

И покажите её в окне: в `FocuslyApp` замените `ContentView()` на `TaskListDraftView()`.

### Что такое @State

View — структура, которую SwiftUI пересоздаёт постоянно. Обычное поле `var tasks` обнулялось бы при каждом пересоздании (и вообще его нельзя менять: `body` не `mutating`). `@State` говорит: «храни это значение **снаружи** структуры, пока View на экране, и перерисовывай View, когда оно меняется».

- `tasks` — читаем текущее значение.
- `$tasks` — **привязка** (`Binding<[FocusTask]>`): ссылка «на чтение и запись» к этому хранилищу. `TextField` и `Toggle` получают привязку и сами меняют значение, когда пользователь печатает или щёлкает.
- `List($tasks) { $task in ... }` — список по привязке к массиву: для каждого элемента вы получаете привязку `$task` к нему, поэтому `Toggle` меняет `isDone` прямо в массиве.

> `@State` всегда делайте `private`. Это внутреннее состояние View; снаружи передают либо значение (для чтения), либо привязку (для изменения).

### @Binding: передать право на изменение

Вынесем строку в отдельный компонент. Ему нужна не копия задачи, а возможность её менять:

```swift
struct TaskRow: View {
    @Binding var task: FocusTask

    var body: some View {
        HStack {
            Toggle("", isOn: $task.isDone)
                .labelsHidden()
            Text(task.title)
                .strikethrough(task.isDone)
            Spacer()
            Text("\(task.completedPomodoros)/\(task.estimate) 🍅")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
```

В списке: `List($tasks) { $task in TaskRow(task: $task) }`.

| Обёртка | Кто владеет данными | Когда использовать |
|---|---|---|
| `@State` | эта View | простое локальное состояние: текст в поле, флаг «показан ли лист» |
| `@Binding` | кто-то выше | дочерней View нужно менять чужое состояние |
| обычный `let` | кто-то выше | View только показывает значение |
| `@Bindable`, `@Environment` | объект ViewModel | уроки 4 и 7 |

### Почему List понимает, какая строка какая

`List` и `ForEach` требуют, чтобы элементы были `Identifiable` (или чтобы вы указали `id:`). По `id` SwiftUI сопоставляет строки между перерисовками: какая добавилась, какая удалилась, какая просто изменилась. Если бы `id` менялся при каждом изменении задачи, SwiftUI считал бы её новой строкой: пропадали бы анимации и сбрасывалось выделение.

### Что здесь плохо

Этот код работает, но посмотрите на него глазами будущего Focusly:

- логика («обрезать пробелы», «не добавлять пустое») живёт в View. Протестировать её можно только кликая мышкой;
- скоро добавятся сохранение на диск, отмена, таймер. Всё это окажется в одной структуре на 500 строк;
- данные живут в одной View. Другое окно или значок в строке меню их не увидит.

> **🧩 Антипаттерн: Massive View.** Когда View одновременно рисует, хранит данные, проверяет ввод, ходит в файлы и в сеть. В UIKit/AppKit был такой же «Massive View Controller». Лечится разделением ответственности — это следующий урок.

Подробнее: [Model data](https://developer.apple.com/documentation/swiftui/model-data), [State](https://developer.apple.com/documentation/swiftui/state)

### Готово, когда

- можно добавить задачу кнопкой и клавишей Return, пустую добавить нельзя;
- отметка «выполнено» работает и зачёркивает название;
- строка вынесена в `TaskRow` с `@Binding`.

### Практика

1. Добавьте удаление задачи через контекстное меню строки (правый клик → «Удалить»). Готово, когда задача исчезает из списка.
   <details><summary>Подсказка</summary>Модификатор <code>.contextMenu { Button(...) }</code> на строке и <code>tasks.removeAll { ... }</code>.</details>
2. Покажите под списком «Осталось: N» — число невыполненных задач. Готово, когда число меняется сразу при отметке задачи.
3. (*) Сделайте превью для `TaskRow`. Проблема: ему нужна привязка, а откуда она в превью? Найдите два способа: «замороженная» привязка и настоящее изменяемое состояние прямо в `#Preview`. Готово, когда во втором варианте галочка в превью щёлкается.
   <details><summary>Подсказка</summary><code>.constant(...)</code> и макрос <code>@Previewable @State</code>.</details>

---

## Урок 4. MVVM и Observer

Вынесем данные и логику из View в отдельный объект — ViewModel — и научимся его тестировать. Это главный архитектурный шаг курса: дальше всё строится на нём.

### Идея

```
 ┌────────────┐  намерения: addTask()   ┌──────────────────┐        ┌───────────┐
 │    View    │ ──────────────────────▶ │    ViewModel     │ ─────▶ │   Model   │
 │  (SwiftUI) │ ◀────────────────────── │  (@Observable)   │        │ FocusTask │
 └────────────┘  состояние: tasks, ...  └──────────────────┘        └───────────┘
   только рисует                          логика и состояние экрана   данные и правила
```

- **View** показывает состояние и сообщает о действиях пользователя. Никакой логики.
- **ViewModel** хранит состояние экрана и решает, что делать с действиями. Ничего не знает про SwiftUI.
- **Model** — данные и их собственные правила (инварианты из урока 2).

### ViewModel в ядре

Создайте `FocuslyCore/Sources/FocuslyCore/TaskListViewModel.swift`:

```swift
import Foundation
import Observation

@MainActor
@Observable
public final class TaskListViewModel {
    public private(set) var tasks: [FocusTask]
    public var newTaskTitle = ""

    public init(tasks: [FocusTask] = []) {
        self.tasks = tasks
    }

    public var canAddTask: Bool {
        !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func addTask() {
        guard canAddTask else { return }
        tasks.append(FocusTask(title: newTaskTitle))
        newTaskTitle = ""
    }

    public func toggleDone(_ id: UUID) {
        // практика 1
    }

    public func delete(_ id: UUID) {
        // практика 1
    }
}
```

Разбор:

- **`class`, а не `struct`.** ViewModel — один объект, на который смотрят разные View. Нужна общая личность, а не копии. `final` — от него не наследуются (и компилятору проще).
- **`@Observable`** (из модуля `Observation`) — макрос, который превращает класс в **наблюдаемый**: SwiftUI запоминает, какие свойства View прочитала в `body`, и перерисовывает её, когда меняются *именно они*. Не весь объект, а конкретные свойства.
- **`@MainActor`** — все свойства и методы используются только на главном потоке, где работает интерфейс. Компилятор Swift 6 следит за этим.
- **`private(set) var tasks`** — менять список может только ViewModel. View не пишет `tasks.append(...)`, а вызывает `addTask()`. Это **однонаправленный поток данных**: состояние течёт вниз, намерения вверх.
- **`newTaskTitle` открыт на запись** — его меняет `TextField` через привязку. Это осознанное исключение: текст в поле ввода и есть состояние экрана.
- Нет `import SwiftUI`. ViewModel можно протестировать без окон.

> **🧩 Паттерн: MVVM (Model–View–ViewModel).** View — тонкая и «глупая», ViewModel — состояние и логика экрана, Model — данные. Выигрыш: логику можно тестировать без интерфейса, а интерфейс можно переделать, не трогая логику.
>
> **🧩 ООП: SRP (Single Responsibility Principle, принцип единственной ответственности).** У типа должна быть одна причина для изменения. View меняется, когда меняется дизайн; ViewModel — когда меняется поведение; модель — когда меняются данные.

### Observer: как View узнаёт об изменениях

> **🧩 Паттерн: Observer (Наблюдатель).** Есть *субъект* с состоянием и *наблюдатели*, которые хотят знать об изменениях. Субъект не знает, кто именно на него смотрит; он только оповещает. В классическом виде у субъекта есть `subscribe(observer)` и при изменении он вызывает `observer.update()` у каждого.
>
> В Swift вы встретите несколько реализаций одной идеи:
>
> | Механизм | Где |
> |---|---|
> | `@Observable` (Observation) | современный SwiftUI — то, что мы используем |
> | `ObservableObject` + `@Published` (Combine) | SwiftUI до 2023 года, много старого кода и статей |
> | `NotificationCenter` | системные события: «приложение уходит в фон», «изменились настройки» |
> | KVO, делегаты, замыкания-колбэки | AppKit и старые API |
>
> `@Observable` делает подписку автоматической: View «подписывается» на те свойства, которые прочитала в `body`.

### Подключаем к View

Перепишите `TaskListDraftView` (или создайте `TaskListView` и переключите на неё окно):

```swift
import FocuslyCore
import SwiftUI

struct TaskListView: View {
    @State private var taskList = TaskListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Новая задача", text: $taskList.newTaskTitle)
                    .onSubmit { taskList.addTask() }
                Button("Добавить", systemImage: "plus") { taskList.addTask() }
                    .disabled(!taskList.canAddTask)
            }
            .padding(8)

            List(taskList.tasks) { task in
                TaskRow(task: task) { taskList.toggleDone(task.id) }
            }
        }
    }
}
```

`TaskRow` теперь получает задачу **значением** и замыкание для действия, а не привязку: менять задачу напрямую больше нельзя, только через ViewModel.

```swift
struct TaskRow: View {
    let task: FocusTask
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
            }
            .buttonStyle(.borderless)
            Text(task.title)
                .strikethrough(task.isDone)
            Spacer()
            Text("\(task.completedPomodoros)/\(task.estimate) 🍅")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
```

> `@State private var taskList = TaskListViewModel()` — правильно: SwiftUI создаст объект один раз и будет хранить его, пока View на экране. А `let taskList = TaskListViewModel()` — ошибка: объект создаётся заново при каждом пересоздании структуры View, и все задачи пропадают в случайный момент.

> Забыли `@Observable` у класса — код соберётся, но интерфейс не будет обновляться. Если «данные меняются, а на экране ничего» — первым делом проверьте это.

### Тестируем ViewModel

`FocuslyCore/Tests/FocuslyCoreTests/TaskListViewModelTests.swift`:

```swift
import Foundation
import Testing
@testable import FocuslyCore

@MainActor
@Suite("TaskListViewModel")
struct TaskListViewModelTests {
    @Test func addsTaskAndClearsField() {
        let vm = TaskListViewModel()
        vm.newTaskTitle = "Написать тесты"
        vm.addTask()
        #expect(vm.tasks.map(\.title) == ["Написать тесты"])
        #expect(vm.newTaskTitle.isEmpty)
    }

    @Test func doesNotAddEmptyTask() {
        let vm = TaskListViewModel()
        vm.newTaskTitle = "   "
        #expect(vm.canAddTask == false)
        vm.addTask()
        #expect(vm.tasks.isEmpty)
    }
}
```

`@MainActor` у набора нужен потому, что ViewModel живёт на главном акторе, а тесты Swift Testing по умолчанию запускаются параллельно на разных потоках. Без пометки компилятор не даст вызвать методы ViewModel.

Сравните с уроком 3: та же логика, но теперь она проверяется за миллисекунды, без кликов.

Подробнее: [Managing model data in your app](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app), [Discover Observation in SwiftUI (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10149/)

### Готово, когда

- в View нет логики, только вызовы методов ViewModel;
- `toggleDone` и `delete` реализованы и покрыты тестами;
- `./scripts/check.sh` зелёный.

### Практика

1. Реализуйте `toggleDone(_:)` и `delete(_:)` и напишите на них тесты. Удаление подключите к контекстному меню строки. Готово, когда тесты зелёные и в приложении всё работает.
   <details><summary>Подсказка</summary>Найти индекс: <code>tasks.firstIndex(where:)</code>. Изменить элемент массива на месте: <code>tasks[index].isDone.toggle()</code>.</details>
2. Перенесите «Осталось: N» из урока 3 в ViewModel как вычисляемое свойство `remainingCount` с тестом. Готово, когда View просто показывает `taskList.remainingCount`.
3. (*) Добавьте в начало `body` строку `let _ = Self._printChanges()` и запустите приложение из Xcode. Печатайте в поле ввода, отмечайте задачи и смотрите в консоль Xcode. Готово, когда вы можете объяснить, почему View перерисовывается и какое свойство это вызвало. Уберите строку после эксперимента.

---

# Часть II. Архитектура

## Урок 5. Протоколы и Repository

Задачи пропадают при перезапуске. Прежде чем писать сохранение в файл, отделим ViewModel от способа хранения, иначе её снова станет невозможно тестировать.

### Проблема

Самое прямолинейное решение — писать файл прямо из ViewModel:

```swift
public func addTask() {
    // ...
    let data = try! JSONEncoder().encode(tasks)
    try! data.write(to: URL(filePath: "/Users/.../tasks.json"))
}
```

Теперь каждый тест ViewModel пишет на диск, тесты мешают друг другу, а смена формата хранения (JSON → база данных) означает переписывание ViewModel. ViewModel отвечает и за экран, и за файлы, то есть SRP нарушен.

### Протокол как контракт

Опишем, *что* нам нужно от хранилища, не говоря *как*. `FocuslyCore/Sources/FocuslyCore/TaskRepository.swift`:

```swift
import Foundation

public protocol TaskRepository {
    func loadTasks() throws -> [FocusTask]
    func saveTasks(_ tasks: [FocusTask]) throws
}
```

И первая реализация — хранение в памяти. Она пригодится для тестов и превью:

```swift
public final class InMemoryTaskRepository: TaskRepository {
    private var storage: [FocusTask]
    public private(set) var saveCount = 0

    public init(tasks: [FocusTask] = []) {
        self.storage = tasks
    }

    public func loadTasks() throws -> [FocusTask] {
        storage
    }

    public func saveTasks(_ tasks: [FocusTask]) throws {
        storage = tasks
        saveCount += 1
    }
}
```

> Здесь `class` выбран сознательно. Тест создаёт хранилище, отдаёт его ViewModel и потом проверяет, что в нём оказалось. Нужна **общая** изменяемая память у теста и ViewModel, то есть ссылочная семантика. Будь это `struct`, ViewModel получила бы копию, а тест смотрел бы в пустой оригинал.

### ViewModel зависит от протокола

```swift
@MainActor
@Observable
public final class TaskListViewModel {
    public private(set) var tasks: [FocusTask] = []
    public var newTaskTitle = ""
    public private(set) var errorMessage: String?

    @ObservationIgnored private let repository: any TaskRepository

    public init(repository: any TaskRepository) {
        self.repository = repository
    }

    public func load() {
        do {
            tasks = try repository.loadTasks()
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось загрузить задачи: \(error.localizedDescription)"
        }
    }

    public func addTask() {
        guard canAddTask else { return }
        tasks.append(FocusTask(title: newTaskTitle))
        newTaskTitle = ""
        persist()
    }

    // toggleDone и delete тоже должны вызывать persist()

    private func persist() {
        do {
            try repository.saveTasks(tasks)
            errorMessage = nil
        } catch {
            errorMessage = "Не удалось сохранить: \(error.localizedDescription)"
        }
    }
}
```

- `any TaskRepository` — **экзистенциальный тип**: «любое значение, которое соответствует протоколу». ViewModel не знает и не хочет знать, что там внутри.
- `@ObservationIgnored` — за этим свойством SwiftUI следить не нужно: оно не меняется и не показывается.
- Ошибки не роняют приложение, а превращаются в состояние `errorMessage`, которое View может показать.

Обновите тесты урока 4: теперь ViewModel создаётся так: `TaskListViewModel(repository: InMemoryTaskRepository())`. И добавьте тест, ради которого всё затевалось:

```swift
@Test func addedTaskIsSaved() throws {
    let repository = InMemoryTaskRepository()
    let vm = TaskListViewModel(repository: repository)
    vm.newTaskTitle = "A"
    vm.addTask()
    #expect(try repository.loadTasks().map(\.title) == ["A"])
}
```

В приложении пока: `@State private var taskList = TaskListViewModel(repository: InMemoryTaskRepository())` и вызов `.task { taskList.load() }` у корневой View. Задачи всё ещё живут в памяти, но ViewModel уже готова к настоящему хранилищу.

> **🧩 Паттерн: Repository (Репозиторий).** Объект, который выглядит для остального кода как коллекция данных и прячет, где и как они хранятся: в памяти, в файле, в базе, на сервере. Код выше репозитория работает с моделями, а не с файлами и SQL.
>
> **🧩 ООП: DIP (Dependency Inversion Principle, принцип инверсии зависимостей).** Модули верхнего уровня (ViewModel) не должны зависеть от модулей нижнего уровня (файлы). Оба зависят от абстракции (протокол `TaskRepository`). Именно это позволяет подсунуть в тест хранилище в памяти.
>
> **🧩 ООП: Полиморфизм.** Один и тот же вызов `repository.saveTasks(...)` делает разное в зависимости от того, какой объект пришёл. В Swift полиморфизм чаще достигается протоколами, чем наследованием.

### Протоколы или наследование

В «классическом» ООП общую часть выносят в базовый класс: `class Repository { func save() { fatalError("override me") } }` и наследуют от него. В Swift так почти не делают:

| | Наследование классов | Протоколы |
|---|---|---|
| кто может соответствовать | только классы | структуры, перечисления, классы, акторы |
| сколько «родителей» | один | сколько угодно протоколов |
| забыли реализовать метод | узнаете при запуске (`fatalError`) | ошибка компиляции |
| общая реализация | в базовом классе | в расширении протокола (`extension`), урок 12 |
| хрупкость | изменение базового класса ломает наследников | протокол — только контракт |

> **Нужно знать: `any`, `some` и дженерики.** Зависимость можно хранить тремя способами:
>
> | Запись | Что значит | Плюсы и минусы |
> |---|---|---|
> | `let repo: any TaskRepository` | любой тип, известен при выполнении | просто; тип можно подменить в любой момент; небольшие накладные расходы |
> | `class VM<R: TaskRepository> { let repo: R }` | конкретный тип, известен при компиляции | быстрее, но тип протекает наружу: `TaskListViewModel<InMemoryTaskRepository>` |
> | `func f(_ repo: some TaskRepository)` | конкретный тип, но скрытый | удобно для параметров и возвращаемых значений |
>
> Для зависимостей ViewModel `any` — нормальный выбор.

Подробнее: [Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/), [Repository (Martin Fowler)](https://martinfowler.com/eaaCatalog/repository.html), [Protocol-Oriented Programming in Swift (WWDC15)](https://developer.apple.com/videos/play/wwdc2015/408/)

### Готово, когда

- ViewModel получает хранилище через `init` и знает о нём только протокол;
- все изменения задач вызывают `persist()`;
- старые тесты обновлены, новые проверяют сохранение.

### Практика

1. Напишите тест «после `toggleDone` задача сохранена» с проверкой `saveCount`. Готово, когда тест падает, если убрать `persist()` из `toggleDone`.
2. Прямо в файле тестов напишите `FailingTaskRepository`, который всегда бросает ошибку, и проверьте, что ViewModel выставляет `errorMessage` и при загрузке, и при сохранении. Готово, когда оба теста зелёные.
   <details><summary>Подсказка</summary>Своя ошибка: <code>struct DiskFull: Error {}</code>, затем <code>throw DiskFull()</code>.</details>
3. (*) Покажите `errorMessage` в интерфейсе через `.alert`. Окно должно закрываться и сбрасывать ошибку. Готово, когда с `FailingTaskRepository` в приложении появляется сообщение и закрывается по кнопке OK.
   <details><summary>Подсказка</summary>Для <code>isPresented</code> нужна привязка <code>Binding&lt;Bool&gt;</code>. Её можно собрать вручную: <code>Binding(get: { ... }, set: { ... })</code>. ViewModel понадобится метод вроде <code>dismissError()</code>.</details>

---

## Урок 6. Файлы, JSON и обобщённое хранилище

Теперь напишем настоящее хранилище на диске и проверим, что оно ведёт себя так же, как хранилище в памяти. По пути познакомимся с дженериками и песочницей macOS.

### Куда сохранять

У каждого приложения на macOS есть папка `Application Support` для своих данных. Приложения из Xcode по умолчанию работают в **песочнице** (App Sandbox): им доступен только собственный контейнер, и `Application Support` на самом деле находится по адресу

```
~/Library/Containers/<bundle id>/Data/Library/Application Support/
```

Код при этом пишет просто `URL.applicationSupportDirectory`, а система подставит путь внутри контейнера. Небольшой помощник:

```swift
import Foundation

public enum AppFolder {
    public static func url(appName: String = "Focusly") -> URL {
        URL.applicationSupportDirectory.appending(path: appName, directoryHint: .isDirectory)
    }
}
```

> `enum` без вариантов — способ сделать «пространство имён» для статических функций: экземпляр такого типа создать невозможно.

### Обобщённое хранилище JSON

Сохранять в JSON придётся не только задачи, но и историю сессий (урок 9). Чтобы не писать одно и то же дважды, сделаем **дженерик**: хранилище для любого `Codable`-значения.

```swift
import Foundation

public struct JSONFileStore<Value: Codable> {
    public let fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func load() throws -> Value? {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            return nil
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Value.self, from: data)
    }

    public func save(_ value: Value) throws {
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(value)
        try data.write(to: fileURL, options: .atomic)
    }
}
```

- `<Value: Codable>` — параметр типа с ограничением: `Value` может быть чем угодно, что умеет кодироваться. `JSONFileStore<[FocusTask]>` и `JSONFileStore<[FocusSession]>` — два разных типа из одного шаблона.
- Файла ещё нет — это не ошибка, а «пока пусто»: возвращаем `nil`.
- `.atomic` — сначала пишем во временный файл, потом подменяем. Если приложение упадёт посреди записи, старый файл останется целым.
- `createDirectory(..., withIntermediateDirectories: true)` создаёт папку `Focusly`, если её нет, и не ругается, если есть.

### Репозиторий поверх хранилища

Теперь `JSONFileTaskRepository` — это `TaskRepository`, который внутри **использует** `JSONFileStore<[FocusTask]>`. Напишите его сами (практика 1) по такому интерфейсу:

```swift
public struct JSONFileTaskRepository: TaskRepository {
    private let store: JSONFileStore<[FocusTask]>

    public init(fileURL: URL) { ... }
    public func loadTasks() throws -> [FocusTask] { ... }  // нет файла → пустой массив
    public func saveTasks(_ tasks: [FocusTask]) throws { ... }
}
```

> **🧩 ООП: Композиция вместо наследования.** `JSONFileTaskRepository` *содержит* хранилище, а не *является* им. Можно было бы сделать базовый класс `JSONFileStore` и наследовать от него репозитории, но тогда репозиторий получил бы наружу все методы хранилища, а сменить способ хранения без переписывания иерархии стало бы нельзя. Композиция гибче: внутреннюю деталь легко подменить.

### Контрактные тесты

Оба репозитория обещают одно и то же: «что сохранил, то и загрузишь». Проверим это **одними и теми же тестами** для обеих реализаций, с помощью параметризованных тестов Swift Testing. `FocuslyCore/Tests/FocuslyCoreTests/TaskRepositoryContractTests.swift`:

```swift
import Foundation
import Testing
@testable import FocuslyCore

struct RepositoryCase: CustomTestStringConvertible, Sendable {
    let name: String
    let make: @Sendable () -> any TaskRepository
    var testDescription: String { name }

    static let all: [RepositoryCase] = [
        RepositoryCase(name: "InMemory") { InMemoryTaskRepository() },
        RepositoryCase(name: "JSONFile") {
            JSONFileTaskRepository(
                fileURL: URL.temporaryDirectory.appending(path: "focusly-\(UUID()).json")
            )
        },
    ]
}

@Suite("TaskRepository contract")
struct TaskRepositoryContractTests {
    @Test(arguments: RepositoryCase.all)
    func emptyByDefault(_ repo: RepositoryCase) throws {
        #expect(try repo.make().loadTasks().isEmpty)
    }

    @Test(arguments: RepositoryCase.all)
    func savedTasksCanBeLoaded(_ repo: RepositoryCase) throws {
        let repository = repo.make()
        var task = FocusTask(title: "Тест", notes: "заметка", estimate: 3)
        task.registerPomodoro()
        try repository.saveTasks([task])
        #expect(try repository.loadTasks() == [task])
    }

    @Test(arguments: RepositoryCase.all)
    func saveReplacesPreviousContent(_ repo: RepositoryCase) throws {
        let repository = repo.make()
        try repository.saveTasks([FocusTask(title: "A"), FocusTask(title: "B")])
        try repository.saveTasks([FocusTask(title: "C")])
        #expect(try repository.loadTasks().map(\.title) == ["C"])
    }
}
```

- `@Test(arguments:)` запускает тест для каждого элемента коллекции; в отчёте видно, какая реализация упала: `repo → JSONFile`.
- Каждый тест получает **новое** хранилище через `make()` и свой уникальный файл во временной папке, поэтому тесты не мешают друг другу даже при параллельном запуске.
- `CustomTestStringConvertible` даёт аргументу понятное имя в отчёте.

> **🧩 ООП: LSP (Liskov Substitution Principle, принцип подстановки Лисков).** Любую реализацию протокола можно подставить вместо другой, и программа останется корректной. Контрактные тесты — способ проверить LSP на практике: если `JSONFile` проходит те же тесты, что `InMemory`, ViewModel не заметит подмены.

### Подключаем в приложении

```swift
@State private var taskList = TaskListViewModel(
    repository: JSONFileTaskRepository(fileURL: AppFolder.url().appending(path: "tasks.json"))
)
```

Добавьте задачи, закройте приложение (**⌘Q**), запустите снова: задачи на месте. Сам файл можно посмотреть:

```bash
ls ~/Library/Containers/com.<ваше-имя>.Focusly/Data/Library/Application\ Support/Focusly/
cat ~/Library/Containers/com.<ваше-имя>.Focusly/Data/Library/Application\ Support/Focusly/tasks.json
```

Подробнее: [Generics](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/), [Parameterized testing](https://developer.apple.com/documentation/testing/parameterizedtesting), [Configuring the macOS App Sandbox](https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox)

### Готово, когда

- `JSONFileTaskRepository` реализован через `JSONFileStore`;
- контрактные тесты проходят для обеих реализаций;
- задачи переживают перезапуск приложения.

### Практика

1. Напишите `JSONFileTaskRepository`. Готово, когда все контрактные тесты зелёные для `JSONFile`.
2. Напишите тест: если в файле мусор (`Data("не json".utf8)`), `loadTasks()` бросает `DecodingError`. Затем испортите настоящий файл в контейнере и запустите приложение. Готово, когда приложение не падает, а показывает ошибку (или хотя бы не теряет файл молча — подумайте, что лучше для пользователя).
   <details><summary>Подсказка</summary><code>#expect(throws: DecodingError.self) { try ... }</code></details>
3. (*) Даты в JSON сейчас выглядят как непонятные числа. Сделайте их читаемыми: `encoder.dateEncodingStrategy = .iso8601` (и такую же стратегию для декодера). Запустите тесты. Готово, когда вы объяснили, почему упал `savedTasksCanBeLoaded`, и выбрали, как поступить: вернуть как было, поменять тест или поменять формат.
   <details><summary>Подсказка</summary>Сравните <code>Date.now.timeIntervalSince1970</code> до и после кодирования. Сколько знаков после запятой хранит ISO 8601 по умолчанию?</details>

---

## Урок 7. Внедрение зависимостей и Composition Root

Скоро у приложения будет несколько ViewModel, хранилищ и сервисов, и им нужно знать друг о друге. Решим, кто их создаёт и как они попадают во View, а заодно сделаем удобные превью с тестовыми данными.

### Проблема

Сейчас View сама создаёт ViewModel и решает, где лежит файл. Это значит:

- превью `TaskListView` пишет в настоящий файл с задачами;
- если таймеру (урок 9) понадобится тот же список задач, он не сможет до него добраться;
- место хранения зашито глубоко в интерфейсе.

### Решение: собрать всё в одном месте

Создайте в приложении `AppDependencies.swift`:

```swift
import FocuslyCore
import Foundation

@MainActor
final class AppDependencies {
    let taskList: TaskListViewModel

    init(taskRepository: any TaskRepository) {
        taskList = TaskListViewModel(repository: taskRepository)
        taskList.load()
    }

    static func live() -> AppDependencies {
        let folder = AppFolder.url()
        return AppDependencies(
            taskRepository: JSONFileTaskRepository(fileURL: folder.appending(path: "tasks.json"))
        )
    }

    static func preview() -> AppDependencies {
        AppDependencies(
            taskRepository: InMemoryTaskRepository(tasks: [
                FocusTask(title: "Прочитать главу про Observation", estimate: 2),
                FocusTask(title: "Сделать урок 4", isDone: true),
            ])
        )
    }
}
```

`FocuslyApp`:

```swift
@main
struct FocuslyApp: App {
    @State private var deps = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environment(deps.taskList)
        }
    }
}
```

> **🧩 Паттерн: Dependency Injection (внедрение зависимостей).** Объект не создаёт свои зависимости сам, а получает их снаружи — чаще всего через `init` (constructor injection). `TaskListViewModel` с урока 5 уже так устроена: она получает репозиторий и не знает, откуда он.
>
> **🧩 Паттерн: Composition Root (корень композиции).** Единственное место в программе, где создаются и связываются все объекты. Только здесь известны конкретные типы (`JSONFileTaskRepository`); весь остальной код знает протоколы. В Focusly это `AppDependencies`.
>
> **🧩 Паттерн: Factory Method (фабричный метод).** `live()` и `preview()` — статические методы, которые создают готовый, правильно настроенный объект. Вызывающему не нужно знать, из каких частей он собирается. Новый вариант сборки (например, для UI-тестов) — новый фабричный метод, остальной код не меняется.

### Environment: зависимости для View

`.environment(deps.taskList)` кладёт объект в **окружение**: его может достать любая View ниже по дереву, не передавая через `init` каждого промежуточного уровня.

```swift
struct TaskListView: View {
    @Environment(TaskListViewModel.self) private var taskList

    var body: some View {
        @Bindable var taskList = taskList
        VStack(spacing: 0) {
            HStack {
                TextField("Новая задача", text: $taskList.newTaskTitle)
                // ...
```

- `@Environment(TaskListViewModel.self)` — достать из окружения объект этого типа.
- `@Bindable var taskList = taskList` — из `@Environment` можно читать, но привязки `$taskList.newTaskTitle` он не даёт. `@Bindable` превращает `@Observable`-объект в источник привязок. Объявить его можно прямо внутри `body`.

| Как View получает объект | Когда |
|---|---|
| `@State private var vm = VM()` | View сама владеет объектом (корень экрана, простые случаи) |
| параметр `init`: `let vm: VM` | явная передача, когда уровней мало |
| `@Environment(VM.self)` | объект нужен многим View на разной глубине |
| `@Bindable var vm` | нужен `$vm.свойство` для `TextField`, `Toggle`, `Picker` |
| `@EnvironmentObject`, `@ObservedObject`, `@StateObject` | старый механизм для `ObservableObject`; в новом коде не нужен |

> Если забыть `.environment(...)` выше по дереву, приложение упадёт при запуске с сообщением вроде «No Observable object of type TaskListViewModel found». Чаще всего это случается в превью.

### Превью с тестовыми данными

```swift
#Preview {
    TaskListView()
        .environment(AppDependencies.preview().taskList)
}
```

Превью больше не трогает настоящий файл и всегда показывает одни и те же данные.

> **🧩 Антипаттерн: Singleton как способ достать зависимость.** Соблазнительно написать `static let shared = TaskListViewModel(...)` и обращаться к `TaskListViewModel.shared` откуда угодно. Это глобальная переменная: в тестах её не подменишь, тесты начинают зависеть друг от друга, а по сигнатуре типа не видно, что он от неё зависит. Системные синглтоны (`FileManager.default`, `UserDefaults.standard`, `UNUserNotificationCenter.current()`) мы будем использовать только на краях: внутри конкретных реализаций протоколов и в composition root.

Подробнее: [Inversion of Control Containers and the Dependency Injection pattern (Martin Fowler)](https://martinfowler.com/articles/injection.html), [Composition Root (Mark Seemann)](https://blog.ploeh.dk/2011/07/28/CompositionRoot/)

### Готово, когда

- ViewModel создаётся только в `AppDependencies`;
- View достают её из окружения;
- превью работают на тестовых данных и не трогают файл.

### Практика

1. Сделайте `preview()` с тремя-четырьмя задачами в разных состояниях (с прогрессом, выполненные). Готово, когда превью `TaskListView` их показывает.
   <details><summary>Подсказка</summary>Прогресс задаче можно добавить через <code>var task = ...; task.registerPomodoro()</code> до передачи в массив.</details>
2. Добавьте второе превью — пустой список: `#Preview("Пусто") { ... }`. Покажите в пустом списке заглушку `ContentUnavailableView`. Готово, когда в canvas переключаются оба превью.
3. (*) Скоро в окружение придётся класть три-четыре объекта, и в каждом превью и каждой сцене повторять одно и то же. Напишите расширение `View` с методом `withDependencies(_ deps: AppDependencies) -> some View`. Готово, когда и `FocuslyApp`, и превью используют его.

---

## Урок 8. Навигация macOS и Strategy

Сделаем «настоящий» интерфейс macOS-приложения: боковая панель с фильтрами, список и подробности выбранной задачи. По ходу появятся фильтры, поиск, сортировка — и паттерн Strategy.

### Три колонки

`NavigationSplitView` — стандартная раскладка Mac-приложений (как в Почте или Заметках):

```swift
struct ContentView: View {
    @Environment(TaskListViewModel.self) private var taskList

    var body: some View {
        @Bindable var taskList = taskList
        NavigationSplitView {
            SidebarView()
        } content: {
            TaskListView()
        } detail: {
            if let task = taskList.selectedTask {
                TaskDetailView(task: task)
                    .id(task.id)
            } else {
                ContentUnavailableView("Выберите задачу", systemImage: "checklist")
            }
        }
        .searchable(text: $taskList.searchText, prompt: "Поиск задач")
    }
}
```

Верните в `FocuslyApp` корневой `ContentView()` вместо `TaskListView()`.

### Фильтры: закрытый набор → enum

Фильтров ровно три, и новые появятся, только если мы сами поменяем приложение. Для такого **закрытого** набора лучше всего подходит `enum`:

```swift
public enum TaskFilter: String, CaseIterable, Identifiable, Sendable {
    case all
    case active
    case done

    public var id: Self { self }

    public var title: String {
        switch self {
        case .all: "Все"
        case .active: "Активные"
        case .done: "Готово"
        }
    }

    public var systemImage: String {
        switch self {
        case .all: "tray.full"
        case .active: "circle"
        case .done: "checkmark.circle"
        }
    }

    public func includes(_ task: FocusTask) -> Bool {
        switch self {
        case .all: true
        case .active: !task.isDone
        case .done: task.isDone
        }
    }
}
```

> В Swift 5.9+ `switch` и `if` могут быть выражениями: ветка `case .all: "Все"` сразу возвращает значение без `return`.

Боковая панель:

```swift
struct SidebarView: View {
    @Environment(TaskListViewModel.self) private var taskList

    var body: some View {
        @Bindable var taskList = taskList
        List(TaskFilter.allCases, selection: Binding($taskList.filter)) { filter in
            Label(filter.title, systemImage: filter.systemImage)
                .tag(filter)
        }
        .navigationSplitViewColumnWidth(min: 160, ideal: 180)
    }
}
```

`List(..., selection:)` ждёт привязку к *опционалу* (выделения может не быть), а `filter` у нас не опционален. `Binding(...)` вокруг привязки делает из `Binding<TaskFilter>` нужный `Binding<TaskFilter?>`.

### Сортировка: открытый набор → Strategy

С сортировкой иначе. Сегодня их три, завтра захочется «сначала срочные», «по оценке», «как я перетащил». Если написать `switch` по вариантам сортировки в ViewModel, каждая новая сортировка будет требовать правки ViewModel. Вынесем алгоритм в отдельный объект:

```swift
public protocol TaskSortStrategy: Sendable {
    var id: String { get }
    var title: String { get }
    func sorted(_ tasks: [FocusTask]) -> [FocusTask]
}

public struct SortByCreationDate: TaskSortStrategy {
    public init() {}
    public var id: String { "created" }
    public var title: String { "По дате создания" }

    public func sorted(_ tasks: [FocusTask]) -> [FocusTask] {
        tasks.sorted { $0.createdAt > $1.createdAt }
    }
}

// SortByTitle и SortByProgress — практика 1

public enum TaskSorting {
    public static let standard: [any TaskSortStrategy] = [
        SortByCreationDate(), SortByTitle(), SortByProgress(),
    ]
}
```

ViewModel получает список доступных стратегий **снаружи** и хранит только идентификатор выбранной:

```swift
public var filter: TaskFilter = .all
public var searchText = ""
public var selectedSortID: String
public var selectedTaskID: UUID?
public let sortStrategies: [any TaskSortStrategy]

public init(
    repository: any TaskRepository,
    sortStrategies: [any TaskSortStrategy] = TaskSorting.standard
) {
    precondition(!sortStrategies.isEmpty, "Нужна хотя бы одна стратегия сортировки")
    self.repository = repository
    self.sortStrategies = sortStrategies
    self.selectedSortID = sortStrategies[0].id
}

public var currentSort: any TaskSortStrategy {
    sortStrategies.first { $0.id == selectedSortID } ?? sortStrategies[0]
}

public var visibleTasks: [FocusTask] {
    let filtered = tasks.filter { task in
        filter.includes(task)
            && (searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText))
    }
    return currentSort.sorted(filtered)
}

public var selectedTask: FocusTask? {
    tasks.first { $0.id == selectedTaskID }
}
```

Выбор сортировки в панели инструментов списка:

```swift
.toolbar {
    Picker("Сортировка", selection: $taskList.selectedSortID) {
        ForEach(taskList.sortStrategies, id: \.id) { strategy in
            Text(strategy.title).tag(strategy.id)
        }
    }
}
```

И сам список теперь показывает `visibleTasks` и умеет выделять:

```swift
List(taskList.visibleTasks, selection: $taskList.selectedTaskID) { task in
    TaskRow(task: task) { taskList.toggleDone(task.id) }
}
```

> **🧩 Паттерн: Strategy (Стратегия).** Семейство взаимозаменяемых алгоритмов, каждый в своём объекте с общим интерфейсом. Код, который их использует (контекст), знает только интерфейс и может поменять алгоритм на лету. Здесь контекст — ViewModel, стратегии — сортировки.
>
> **🧩 ООП: OCP (Open/Closed Principle, принцип открытости/закрытости).** Код открыт для расширения, но закрыт для изменения. Новую сортировку можно добавить, *не трогая* `TaskListViewModel`: написать новую структуру и передать её в `sortStrategies`.

**Когда enum, а когда протокол:**

| | `enum` + `switch` | протокол + типы (Strategy) |
|---|---|---|
| набор вариантов | закрытый, известен заранее | открытый, может расти |
| новый вариант | правка enum и всех `switch` (компилятор подскажет, где) | новый тип, старый код не меняется |
| добавить новую *операцию* над всеми вариантами | легко: ещё один метод с `switch` | нужно менять протокол и все типы |
| пример в Focusly | `TaskFilter` | `TaskSortStrategy` |

> В Swift стратегию часто делают легче — значением с замыканием: `struct TaskSort { let title: String; let areInIncreasingOrder: (FocusTask, FocusTask) -> Bool }` и `static let byTitle = TaskSort(...)`. Это та же идея без отдельного типа на каждый вариант. Протокол удобнее, когда у стратегии несколько методов или своё состояние.

### Подробности задачи

Подробности редактируют **черновик** — локальную копию задачи — и сохраняют её одним действием:

```swift
struct TaskDetailView: View {
    @Environment(TaskListViewModel.self) private var taskList
    @State private var draft: FocusTask

    init(task: FocusTask) {
        _draft = State(initialValue: task)
    }

    var body: some View {
        Form {
            Section("Задача") {
                TextField("Название", text: $draft.title)
                TextField("Заметки", text: $draft.notes, axis: .vertical)
                    .lineLimit(3...8)
                Stepper("Оценка: \(draft.estimate) 🍅", value: $draft.estimate, in: 1...20)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            Button("Сохранить") { taskList.update(draft) }
                .keyboardShortcut("s")
        }
    }
}
```

- `_draft = State(initialValue: task)` — так задаётся начальное значение `@State` из параметра. Подчёркивание даёт доступ к самой обёртке.
- `FocusTask` — структура, поэтому `draft` — независимая копия. Пока пользователь печатает, список не меняется. Ещё одна польза value-семантики.

> **Ловушка: `@State` инициализируется один раз.** Пока View с тем же *идентификатором* остаётся на экране, SwiftUI сохраняет её `@State` и игнорирует новое `initialValue`. Без `.id(task.id)` в `ContentView` при выборе другой задачи в подробностях остался бы черновик старой. `.id(...)` говорит: «это другая View», и SwiftUI создаёт её заново.

Подробнее: [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview), [Strategy (refactoring.guru)](https://refactoring.guru/ru/design-patterns/strategy), [Demystify SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10022/) — про идентичность View

### Готово, когда

- окно в три колонки: фильтры, список, подробности;
- работают фильтр, поиск и переключение сортировки;
- задачу можно отредактировать и сохранить.

### Практика

1. Напишите `SortByTitle` (без учёта регистра, как в Finder) и `SortByProgress` (сначала самые продвинутые) с тестами. Готово, когда тест `["бета", "Альфа"] → ["Альфа", "бета"]` зелёный.
   <details><summary>Подсказка</summary><code>localizedStandardCompare(_:)</code> сравнивает строки так, как это делает Finder.</details>
2. Реализуйте `update(_ task: FocusTask)` в ViewModel: заменить задачу с тем же `id` и сохранить. Если ничего не изменилось, не сохранять. Готово, когда есть тесты на оба случая (через `saveCount`).
3. (*) Докажите OCP: добавьте сортировку «Сначала невыполненные» **в таргете приложения**, не меняя ни одного файла ядра, и подключите её в `AppDependencies`. Готово, когда она появилась в меню сортировки.

---

## Урок 9. Таймер: конечный автомат, Delegate, конкурентность

Главная фича Focusly — таймер. Его логика — классический конечный автомат, и мы напишем её через тесты: сначала спецификация, потом реализация. Затем подключим таймер к задачам через делегат и запустим отсчёт с помощью `Task`.

### Модели

В ядро добавьте (код дан полностью):

```swift
import Foundation

public enum TimerPhase: String, Codable, Sendable, CaseIterable {
    case focus
    case shortBreak
    case longBreak
}

public struct PomodoroSettings: Codable, Equatable, Sendable {
    public var focusMinutes = 25
    public var shortBreakMinutes = 5
    public var longBreakMinutes = 15
    public var sessionsBeforeLongBreak = 4

    public init() {}

    public func seconds(for phase: TimerPhase) -> Int {
        switch phase {
        case .focus: focusMinutes * 60
        case .shortBreak: shortBreakMinutes * 60
        case .longBreak: longBreakMinutes * 60
        }
    }
}

public struct FocusSession: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let taskID: UUID?
    public let startedAt: Date
    public let duration: TimeInterval

    public init(id: UUID = UUID(), taskID: UUID?, startedAt: Date, duration: TimeInterval) {
        self.id = id
        self.taskID = taskID
        self.startedAt = startedAt
        self.duration = duration
    }
}
```

### Автомат: состояния × события

Таймер может быть в одном из трёх **состояний** и получать пять **событий**. Что происходит — полностью определяется парой (состояние, событие):

| состояние \ событие | `start` | `pause` | `tick` (прошла секунда) | `reset` | `skip` |
|---|---|---|---|---|---|
| `idle` | → `running` | — | — | заново текущая фаза | следующая фаза, `idle` |
| `running` | — | → `paused` | −1 секунда; на нуле — фаза завершена, следующая, `idle` | → `idle`, заново | следующая фаза, `idle` |
| `paused` | → `running` | — | — | → `idle`, заново | следующая фаза, `idle` |

Правила смены фазы:

- после `focus` идёт `shortBreak`, а каждый N-й завершённый фокус (`sessionsBeforeLongBreak`) — `longBreak`;
- после любого перерыва — `focus`;
- `skip` фокуса **не** засчитывает его как завершённый.

Интерфейс автомата (тело `handle` — практика 1):

```swift
public struct PomodoroTimer: Equatable, Sendable {
    public enum State: Equatable, Sendable {
        case idle
        case running
        case paused
    }

    public enum Event: Sendable {
        case start
        case pause
        case reset
        case skip
        case tick
    }

    public enum Outcome: Equatable, Sendable {
        case none
        case finished(TimerPhase)
    }

    public private(set) var state: State = .idle
    public private(set) var phase: TimerPhase = .focus
    public private(set) var remainingSeconds: Int
    public private(set) var completedFocusSessions = 0
    public private(set) var settings: PomodoroSettings

    public init(settings: PomodoroSettings = PomodoroSettings()) {
        self.settings = settings
        self.remainingSeconds = settings.seconds(for: .focus)
    }

    @discardableResult
    public mutating func handle(_ event: Event) -> Outcome {
        // практика 1: switch (state, event) { ... }
        .none
    }
}
```

Автомат — **структура без таймеров, часов и потоков**. Время в него приходит снаружи событием `.tick`. Поэтому его можно проверить мгновенно и детерминированно: «прошло 60 секунд» — это 60 вызовов `handle(.tick)`.

### Спецификация в тестах

Наберите тесты **до** реализации. Сейчас они упадут — это нормально. Ваша задача — сделать их зелёными.

```swift
import Testing
@testable import FocuslyCore

@Suite("PomodoroTimer")
struct PomodoroTimerTests {
    func makeTimer(focus: Int = 1, short: Int = 1, long: Int = 2, every: Int = 2) -> PomodoroTimer {
        var settings = PomodoroSettings()
        settings.focusMinutes = focus
        settings.shortBreakMinutes = short
        settings.longBreakMinutes = long
        settings.sessionsBeforeLongBreak = every
        return PomodoroTimer(settings: settings)
    }

    @Test func startsIdleWithFullFocus() {
        let timer = makeTimer(focus: 25)
        #expect(timer.state == .idle)
        #expect(timer.phase == .focus)
        #expect(timer.remainingSeconds == 25 * 60)
    }

    @Test func tickIsIgnoredWhenNotRunning() {
        var timer = makeTimer()
        timer.handle(.tick)
        #expect(timer.remainingSeconds == 60)
        timer.handle(.start)
        timer.handle(.pause)
        timer.handle(.tick)
        #expect(timer.remainingSeconds == 60)
    }

    @Test func runningTimerCountsDown() {
        var timer = makeTimer()
        timer.handle(.start)
        timer.handle(.tick)
        #expect(timer.state == .running)
        #expect(timer.remainingSeconds == 59)
    }

    @Test func focusEndsWithShortBreak() {
        var timer = makeTimer()
        timer.handle(.start)
        var outcome = PomodoroTimer.Outcome.none
        for _ in 0..<60 { outcome = timer.handle(.tick) }
        #expect(outcome == .finished(.focus))
        #expect(timer.phase == .shortBreak)
        #expect(timer.state == .idle)
        #expect(timer.completedFocusSessions == 1)
        #expect(timer.remainingSeconds == 60)
    }

    @Test func everySecondFocusEndsWithLongBreak() {
        var timer = makeTimer(every: 2)
        for _ in 0..<2 {
            timer.handle(.start)
            for _ in 0..<60 { timer.handle(.tick) }
            if timer.phase == .shortBreak { timer.handle(.skip) }
        }
        #expect(timer.phase == .longBreak)
        #expect(timer.remainingSeconds == 120)
    }

    @Test func skippedFocusIsNotCounted() {
        var timer = makeTimer()
        timer.handle(.start)
        timer.handle(.skip)
        #expect(timer.phase == .shortBreak)
        #expect(timer.completedFocusSessions == 0)
    }

    @Test func resetRestoresPhaseDuration() {
        var timer = makeTimer()
        timer.handle(.start)
        timer.handle(.tick)
        timer.handle(.reset)
        #expect(timer.state == .idle)
        #expect(timer.remainingSeconds == 60)
    }
}
```

```bash
./scripts/check.sh test PomodoroTimer
```

> **🧩 Паттерн: State (Состояние) и конечный автомат.** Поведение объекта зависит от его состояния, а переходы между состояниями явно описаны. В книге «банды четырёх» (GoF) каждое состояние — отдельный класс с методами `start()`, `pause()`…, а объект-контекст делегирует вызовы текущему состоянию и подменяет его при переходе. В Swift то же самое обычно выражают `enum` и `switch` по паре `(state, event)`: компилятор проверяет, что все пары разобраны, а вся таблица переходов видна в одном месте.
>
> Вариант с классами становится лучше, когда у каждого состояния много своей логики и данных (например, у состояний сетевого соединения: свой таймаут, своя очередь сообщений). Для таймера хватает `enum`.

> **Нужно знать: `switch` по кортежу.** `switch (state, event)` перебирает пары. Шаблон `case (.idle, .start), (.paused, .start):` объединяет две пары в одной ветке, `case (_, .reset):` срабатывает при любом состоянии, `default: break` — «всё остальное игнорируем».

### История сессий

Каждый завершённый фокус нужно записать в историю, чтобы потом построить статистику (урок 12). Хранилище сессий устроено так же, как хранилище задач, — напишите его по образцу (практика 2):

```swift
public protocol SessionRepository {
    func loadSessions() throws -> [FocusSession]
    func saveSessions(_ sessions: [FocusSession]) throws
}
// InMemorySessionRepository и JSONFileSessionRepository — по аналогии с уроками 5–6
```

А сам журнал — маленький наблюдаемый объект, общий для таймера и будущего окна статистики:

```swift
@MainActor
@Observable
public final class SessionLog {
    public private(set) var sessions: [FocusSession] = []
    @ObservationIgnored private let repository: any SessionRepository

    public init(repository: any SessionRepository) {
        self.repository = repository
        sessions = (try? repository.loadSessions()) ?? []
    }

    public func record(_ session: FocusSession) {
        sessions.append(session)
        try? repository.saveSessions(sessions)
    }
}
```

### Delegate: таймер сообщает о завершённом фокусе

Когда фокус над задачей завершён, у задачи должен прибавиться помидор. Но таймер не должен зависеть от `TaskListViewModel`: ему всё равно, кто и как ведёт список задач. Он просто сообщает «я закончил» тому, кто подписался:

```swift
@MainActor
public protocol FocusTimerDelegate: AnyObject {
    func focusTimer(_ timer: FocusTimerViewModel, didCompleteFocusOn taskID: UUID?)
}
```

А `TaskListViewModel` подписывается, реализуя протокол в расширении:

```swift
extension TaskListViewModel: FocusTimerDelegate {
    public func focusTimer(_ timer: FocusTimerViewModel, didCompleteFocusOn taskID: UUID?) {
        guard let taskID else { return }
        registerPomodoro(for: taskID)   // найти задачу, task.registerPomodoro(), persist()
    }
}
```

> **🧩 Паттерн: Delegate (Делегат).** Объект передаёт часть решений или уведомлений другому объекту через протокол. На делегатах построен весь AppKit (`NSWindowDelegate`, `NSApplicationDelegate`, `NSTableViewDataSource`), так что встречаться с ним вы будете постоянно. От Observer отличается тем, что делегат обычно **один**, и он может не только узнать о событии, но и повлиять на поведение («можно ли закрыть окно?»).

> **Ловушка: цикл сильных ссылок.** Делегат хранится как `weak var delegate`. Если бы ссылка была сильной, а делегат, в свою очередь, держал таймер, два объекта держали бы друг друга, и ни один никогда не освободился бы из памяти. `weak` возможен только для классов, поэтому протокол ограничен `AnyObject`.

### ViewModel таймера и отсчёт времени

Тут впервые появляется настоящая асинхронность, поэтому код дан почти целиком:

```swift
@MainActor
@Observable
public final class FocusTimerViewModel {
    public private(set) var timer: PomodoroTimer
    public var currentTaskID: UUID?
    @ObservationIgnored public weak var delegate: (any FocusTimerDelegate)?

    @ObservationIgnored private let log: SessionLog
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var tickTask: Task<Void, Never>?

    public init(
        log: SessionLog,
        settings: PomodoroSettings = PomodoroSettings(),
        now: @escaping () -> Date = { .now }
    ) {
        self.log = log
        self.now = now
        self.timer = PomodoroTimer(settings: settings)
    }

    public var isRunning: Bool { timer.state == .running }

    public var remainingText: String {
        let seconds = max(0, timer.remainingSeconds)
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    public func send(_ event: PomodoroTimer.Event) {
        let outcome = timer.handle(event)
        if timer.state == .running {
            if tickTask == nil { startTicking() }
        } else {
            stopTicking()
        }
        if case .finished(let phase) = outcome {
            didFinish(phase)
        }
    }

    private func didFinish(_ phase: TimerPhase) {
        guard phase == .focus else { return }
        // практика 3: записать FocusSession в log и сообщить делегату
    }

    private func startTicking() {
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                self.send(.tick)
            }
        }
    }

    private func stopTicking() {
        tickTask?.cancel()
        tickTask = nil
    }
}
```

> **Нужно знать: `Task`, `await` и главный актор.**
> - `Task { ... }` запускает асинхронную работу. Созданная внутри `@MainActor`-класса задача тоже выполняется на главном акторе, поэтому из неё можно спокойно менять `timer` и вызывать `send`.
> - `try? await Task.sleep(for: .seconds(1))` — «засыпает» на секунду, **не блокируя** главный поток: интерфейс в это время продолжает работать. `await` — точка, где функция может приостановиться.
> - `tickTask?.cancel()` не убивает задачу мгновенно, а выставляет флаг. Поэтому внутри цикла мы проверяем `Task.isCancelled`. `Task.sleep` при отмене сразу бросает ошибку, и `try?` её глушит.
> - `[weak self]` и `guard let self` — чтобы задача не держала ViewModel вечно. Если ViewModel освободится, цикл закончится сам.
> - `now: () -> Date` — время тоже зависимость. В приложении это `{ .now }`, а в тесте можно подставить фиксированную дату.

И представление (в приложении):

```swift
struct TimerView: View {
    @Environment(FocusTimerViewModel.self) private var timer

    var body: some View {
        VStack(spacing: 12) {
            Text(timer.timer.phase.title)
                .font(.headline)
            Text(timer.remainingText)
                .font(.system(size: 48, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
            HStack {
                if timer.isRunning {
                    Button("Пауза", systemImage: "pause.fill") { timer.send(.pause) }
                } else {
                    Button("Старт", systemImage: "play.fill") { timer.send(.start) }
                }
                Button("Сброс", systemImage: "arrow.counterclockwise") { timer.send(.reset) }
                Button("Пропустить", systemImage: "forward.end") { timer.send(.skip) }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

extension TimerPhase {
    var title: String {
        switch self {
        case .focus: "Фокус"
        case .shortBreak: "Короткий перерыв"
        case .longBreak: "Длинный перерыв"
        }
    }
}
```

> Обратите внимание: русские названия фаз живут в **приложении**, а не в ядре. Ядро описывает смысл (`.shortBreak`), а как его показать — решает интерфейс.

Подключение в `AppDependencies`:

```swift
let taskList: TaskListViewModel
let sessionLog: SessionLog
let timer: FocusTimerViewModel

init(taskRepository: any TaskRepository, sessionRepository: any SessionRepository) {
    taskList = TaskListViewModel(repository: taskRepository)
    sessionLog = SessionLog(repository: sessionRepository)
    timer = FocusTimerViewModel(log: sessionLog)
    timer.delegate = taskList
    taskList.load()
}
```

В `TaskDetailView` добавьте секцию с таймером и кнопкой «Работать над этой задачей», которая выставляет `timer.currentTaskID = draft.id` и отправляет `.start`. Не забудьте положить `timer` и `sessionLog` в окружение.

> Чтобы проверять руками, не дожидаясь 25 минут, временно передайте в `live()` настройки с `focusMinutes = 1`.

Подробнее: [State (refactoring.guru)](https://refactoring.guru/ru/design-patterns/state), [Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/), [Automatic Reference Counting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/) — про `weak` и циклы ссылок, [Embracing Swift concurrency (WWDC25)](https://developer.apple.com/videos/play/wwdc2025/268/)

### Готово, когда

- все тесты `PomodoroTimer` зелёные;
- в приложении таймер считает, ставится на паузу, сбрасывается, пропускает фазу;
- после фокуса над задачей у неё прибавляется помидор, а сессия сохраняется в `sessions.json`.

### Практика

1. Реализуйте `handle(_:)`. Готово, когда все тесты `PomodoroTimer` зелёные.
   <details><summary>Подсказка</summary>Вынесите переход в следующую фазу в приватный <code>mutating func</code>: он нужен и для <code>tick</code> на нуле, и для <code>skip</code>. Разница между ними одна — засчитывать ли фокус.</details>
2. Напишите `InMemorySessionRepository`, `JSONFileSessionRepository` и контрактные тесты для них. Готово, когда тесты зелёные.
   <details><summary>Подсказка</summary>Подумайте, нельзя ли переиспользовать <code>JSONFileStore</code> из урока 6. Для этого он и делался обобщённым.</details>
3. Допишите `didFinish(_:)`: запишите `FocusSession` (начало = `now()` минус длительность фокуса) и сообщите делегату. Напишите тест: таймер с фокусом в 1 минуту, 60 событий `.tick` → в журнале одна сессия с нужным `taskID`, делегат вызван один раз. Готово, когда тест зелёный.
   <details><summary>Подсказка</summary>Делегата для теста напишите прямо в файле тестов: <code>final class SpyDelegate: FocusTimerDelegate</code>, который складывает полученные <code>taskID</code> в массив.</details>
4. (*) `Task.sleep` не гарантирует ровно секунду, а когда приложение в фоне, macOS может притормаживать таймеры (App Nap). За 25 минут отставание может стать заметным. Сделайте таймер точным: при старте запоминайте момент окончания и на каждом тике пересчитывайте остаток от `now()`. Готово, когда есть тест, в котором `now` сдвигается вручную, и остаток считается правильно.

---

# Часть III. Возможности macOS

## Урок 10. Command, отмена действий и меню

Mac-пользователь ждёт, что **⌘Z** отменит последнее действие. Сделаем отмену для добавления, удаления и изменения задач, а заодно разберёмся с меню и горячими клавишами.

### Проблема

Чтобы отменить действие, нужно помнить, *что именно* было сделано и *как* это откатить. Если разбросать это по методам ViewModel (`addTask` запоминает одно, `delete` — другое), получится клубок флагов. Сделаем каждое действие **объектом**, который умеет и выполниться, и откатиться.

### Действие как объект

```swift
public protocol TaskCommand {
    var title: String { get }                     // для меню: «Отменить «Удаление»»
    func execute(on tasks: inout [FocusTask])
    func undo(on tasks: inout [FocusTask])
}

public struct AddTaskCommand: TaskCommand {
    public let task: FocusTask
    public init(task: FocusTask) { self.task = task }
    public var title: String { "Добавление задачи" }

    public func execute(on tasks: inout [FocusTask]) {
        tasks.append(task)
    }

    public func undo(on tasks: inout [FocusTask]) {
        tasks.removeAll { $0.id == task.id }
    }
}
```

- Команда — **структура**, значение: в ней хранится всё, что нужно для выполнения и отката.
- `inout [FocusTask]` — команда получает массив, с которым работает (это *получатель* команды), и меняет его на месте. Сама команда ничего не хранит про ViewModel, поэтому тестируется на обычном массиве.

Ещё две команды напишите сами (практика 1):

```swift
public struct DeleteTasksCommand: TaskCommand {
    public init(ids: Set<UUID>, in tasks: [FocusTask])  // запомнить удаляемые задачи И их позиции
    // undo возвращает задачи на прежние места
}

public struct UpdateTaskCommand: TaskCommand {
    public init(old: FocusTask, new: FocusTask)          // покрывает и «отметить выполненной», и редактирование
}
```

### История

```swift
public struct CommandHistory {
    public init(limit: Int = 50)
    public var canUndo: Bool { get }
    public var canRedo: Bool { get }
    public var undoTitle: String? { get }
    public mutating func record(_ command: any TaskCommand)   // новая команда очищает redo
    public mutating func popUndo() -> (any TaskCommand)?      // перекладывает команду в redo
    public mutating func popRedo() -> (any TaskCommand)?      // перекладывает обратно в undo
}
```

Внутри — два стека: `undoStack` и `redoStack`. Реализация — практика 1.

### ViewModel через команды

Все изменения задач теперь идут через одну точку:

```swift
private var history = CommandHistory()

public var canUndo: Bool { history.canUndo }
public var canRedo: Bool { history.canRedo }
public var undoTitle: String? { history.undoTitle }

private func perform(_ command: any TaskCommand) {
    command.execute(on: &tasks)
    history.record(command)
    persist()
}

public func addTask() {
    guard canAddTask else { return }
    perform(AddTaskCommand(task: FocusTask(title: newTaskTitle)))
    newTaskTitle = ""
}

public func undo() {
    guard let command = history.popUndo() else { return }
    command.undo(on: &tasks)
    persist()
}

// redo — зеркально
```

Перепишите `toggleDone`, `update` и `delete` на команды. `history` **не** помечайте `@ObservationIgnored`: от неё зависит, активен ли пункт меню «Отменить».

> **🧩 Паттерн: Command (Команда).** Запрос превращается в объект. Его можно сохранить, поставить в очередь, отменить, повторить, записать в журнал. Участники: команда (`AddTaskCommand`), получатель (массив задач), инициатор (ViewModel, который вызывает `execute`), история.
>
> Системный `UndoManager` в AppKit и SwiftUI — готовая реализация того же паттерна: вы регистрируете замыкание «как откатить», а он хранит стек и сам подписывает пункты меню.

**Command или снимок состояния (Memento):**

| | Command | Memento (снимок) |
|---|---|---|
| что хранится | действие и данные для отката | весь массив задач до изменения |
| память | мало | весь список на каждый шаг |
| сложность | у каждой команды свой `undo` | один универсальный механизм |
| когда лучше | действия разнообразны, данных много | данных мало, а откатывать сложно |

Для Focusly подошли бы оба варианта; Command мы выбрали, потому что он лучше показывает идею «действие — это объект».

### Меню и горячие клавиши

Меню приложения описывается в сцене через `.commands`. Создайте в приложении `TaskCommands.swift`:

```swift
import FocuslyCore
import SwiftUI

struct TaskCommands: Commands {
    let taskList: TaskListViewModel

    var body: some Commands {
        CommandGroup(replacing: .undoRedo) {
            Button(taskList.undoTitle.map { "Отменить «\($0)»" } ?? "Отменить") {
                taskList.undo()
            }
            .keyboardShortcut("z")
            .disabled(!taskList.canUndo)

            Button("Повторить") { taskList.redo() }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!taskList.canRedo)
        }
        CommandMenu("Задачи") {
            Button("Отметить выполненной") {
                if let id = taskList.selectedTaskID { taskList.toggleDone(id) }
            }
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(taskList.selectedTaskID == nil)
        }
    }
}
```

И подключите к окну: `WindowGroup { ... }.commands { TaskCommands(taskList: deps.taskList) }`.

- `CommandGroup(replacing: .undoRedo)` заменяет стандартные пункты «Отменить/Повторить» в меню «Правка». Есть также `before:` и `after:`, чтобы добавить свои пункты рядом со стандартными.
- `CommandMenu("Задачи")` добавляет новое меню в строку меню.
- `.keyboardShortcut("z")` — по умолчанию с ⌘.

Удаление клавишей Delete — модификатор у списка:

```swift
.onDeleteCommand {
    if let id = taskList.selectedTaskID { taskList.delete([id]) }
}
```

> **Ловушка.** Заменив `.undoRedo`, мы перехватили ⌘Z целиком: теперь, когда курсор в текстовом поле, ⌘Z отменяет не набранный текст, а последнее действие с задачами. В учебном проекте это допустимо. «Правильное» решение — системный `UndoManager` (практика 3): он сам различает, где сейчас фокус.

Подробнее: [Command (refactoring.guru)](https://refactoring.guru/ru/design-patterns/command), [Building and customizing the menu bar with SwiftUI](https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui), [UndoManager](https://developer.apple.com/documentation/foundation/undomanager)

### Готово, когда

- добавление, удаление, отметка и редактирование отменяются по ⌘Z и повторяются по ⇧⌘Z;
- пункт меню показывает, что именно отменится;
- после отмены изменения сохранены на диск;
- тесты команд и истории зелёные.

### Практика

1. Реализуйте `DeleteTasksCommand`, `UpdateTaskCommand` и `CommandHistory`. Начните с тестов: удаление задач A и C из [A, B, C] и отмена → снова [A, B, C] в том же порядке; новая команда после отмены очищает «повторить». Готово, когда тесты зелёные.
   <details><summary>Подсказка</summary>Позиции удобно запомнить в <code>init</code> через <code>tasks.enumerated()</code>. При отмене вставляйте обратно по возрастанию позиций: тогда каждая вставка ставит элемент ровно туда, где он был.</details>
2. Тест «отмена сохраняется»: добавить задачу, отменить, проверить, что в репозитории пусто. Готово, когда тест падает, если убрать `persist()` из `undo()`.
3. (*) Переведите отмену на системный `UndoManager`: достаньте его из окружения (`@Environment(\.undoManager)`) и регистрируйте откат при каждом действии. Уберите `CommandGroup(replacing: .undoRedo)`. Готово, когда ⌘Z в текстовом поле отменяет текст, а вне поля — действие с задачей. Сравните, что стало проще и что сложнее.

---

## Урок 11. Decorator и Adapter: логи и уведомления

Добавим две «служебные» возможности: журнал работы хранилища и системные уведомления о конце фокуса. Обе — без единой правки в ViewModel. Так работают паттерны Decorator и Adapter.

### Логирование через Decorator

Хочется видеть в логах, когда и сколько задач сохранилось. Можно вставить `print` в `JSONFileTaskRepository`, но тогда логирование есть только у одной реализации и навсегда вшито в неё. Вместо этого **обернём** любой репозиторий:

```swift
import Foundation
import os

public struct LoggingTaskRepository: TaskRepository {
    private let wrapped: any TaskRepository
    private let logger = Logger(subsystem: "Focusly", category: "storage")

    public init(wrapping wrapped: any TaskRepository) {
        self.wrapped = wrapped
    }

    public func loadTasks() throws -> [FocusTask] {
        do {
            let tasks = try wrapped.loadTasks()
            logger.debug("Загружено задач: \(tasks.count)")
            return tasks
        } catch {
            logger.error("Ошибка загрузки: \(error.localizedDescription)")
            throw error
        }
    }

    public func saveTasks(_ tasks: [FocusTask]) throws {
        let start = ContinuousClock.now
        try wrapped.saveTasks(tasks)
        logger.debug("Сохранено задач: \(tasks.count) за \(ContinuousClock.now - start)")
    }
}
```

Подключение — одна строка в `AppDependencies.live()`:

```swift
taskRepository: LoggingTaskRepository(
    wrapping: JSONFileTaskRepository(fileURL: folder.appending(path: "tasks.json"))
)
```

Логи смотрите в приложении **Console** (фильтр `Focusly`) или в терминале:

```bash
log stream --predicate 'subsystem == "Focusly"' --level debug
```

> **🧩 Паттерн: Decorator (Декоратор).** Объект-обёртка реализует тот же интерфейс, что и оборачиваемый, и добавляет поведение до или после делегирования вызова. Обёртки можно вкладывать друг в друга: `Logging(Caching(JSONFile(...)))`. Тот, кто пользуется репозиторием, не знает, сколько слоёв внутри.
>
> **Почему не наследование.** `class LoggingJSONRepository: JSONFileTaskRepository` добавил бы логи только к JSON-версии. Для `InMemory` пришлось бы писать второй подкласс, для комбинации «логи + кеш» — третий. Декоратор работает с **любой** реализацией протокола, и комбинации собираются в composition root.

> `Logger` из модуля `os` — системный журнал macOS. Он быстрее `print`, сообщения можно фильтровать по подсистеме и категории, а уровень `debug` в релизной сборке почти ничего не стоит. Для приложений используйте его, а не `print`.

### Уведомления через Adapter

Когда фокус закончился, а пользователь в другом приложении, нужно системное уведомление. За них отвечает `UserNotifications`. Но:

- его API не похоже на то, что нужно нашей ViewModel (запросы, контент, центр уведомлений, разрешения);
- в тестах и превью настоящие уведомления не нужны, а `UNUserNotificationCenter.current()` вне настоящего приложения вообще падает.

Опишем интерфейс, удобный **нам**:

```swift
public protocol Notifier {
    func requestPermission()
    func send(title: String, body: String)
}
```

И «пустую» реализацию для превью и тестов:

```swift
public struct SilentNotifier: Notifier {
    public init() {}
    public func requestPermission() {}
    public func send(title: String, body: String) {}
}
```

А настоящая реализация — `UserNotificationsNotifier` — **адаптирует** системный API к нашему протоколу. Её вы напишете сами (практика 1):

```swift
import UserNotifications

public struct UserNotificationsNotifier: Notifier {
    private let center: UNUserNotificationCenter
    public init(center: UNUserNotificationCenter = .current()) { ... }
    public func requestPermission() { ... }        // разрешение на .alert и .sound
    public func send(title: String, body: String) { ... }
}
```

Подключите `notifier` к `FocusTimerViewModel` через `init` (рядом с `log`). При `.start` ViewModel запрашивает разрешение (система спросит один раз), при завершении фазы отправляет уведомление: «Фокус завершён» или «Перерыв окончен». В тестах передавайте `SilentNotifier()` или шпиона:

```swift
final class SpyNotifier: Notifier {
    var sent: [String] = []
    func requestPermission() {}
    func send(title: String, body: String) { sent.append(title) }
}
```

> **🧩 Паттерн: Adapter (Адаптер).** Обёртка, которая приводит чужой интерфейс к тому, который ожидает ваш код. Адаптеры живут на границе приложения и внешнего мира: системные API, сторонние библиотеки, сеть. Если Apple поменяет API уведомлений, переписать придётся один файл.
>
> **🧩 Паттерн: Null Object (Пустой объект).** `SilentNotifier` — реализация, которая честно ничего не делает. Это лучше, чем `notifier: Notifier?` и проверки `if let notifier` по всему коду.

> **Ловушка: уведомление не появляется.** Если приложение активно (окно на переднем плане), macOS по умолчанию не показывает баннер. Проверяйте так: фокус на 1 минуту → старт → переключитесь в другое приложение. Чтобы баннер показывался и в активном приложении, нужен делегат центра уведомлений (практика 3).

Подробнее: [Decorator](https://refactoring.guru/ru/design-patterns/decorator), [Adapter](https://refactoring.guru/ru/design-patterns/adapter), [Logger](https://developer.apple.com/documentation/os/logger), [User Notifications](https://developer.apple.com/documentation/usernotifications)

### Готово, когда

- в Console видны сообщения о загрузке и сохранении задач;
- по окончании фокуса приходит системное уведомление;
- ViewModel не импортирует `UserNotifications` и не знает про `os.Logger`;
- в тестах таймера используется шпион или `SilentNotifier`.

### Практика

1. Напишите `UserNotificationsNotifier`. Готово, когда уведомление приходит, пока вы в другом приложении.
   <details><summary>Подсказка</summary>Нужны <code>center.requestAuthorization(options:completionHandler:)</code>, <code>UNMutableNotificationContent</code>, <code>UNNotificationRequest(identifier:content:trigger:)</code> с <code>trigger: nil</code> («показать сразу») и <code>center.add(_:withCompletionHandler:)</code>.</details>
2. Напишите тест: по окончании фокуса шпион получил ровно одно уведомление с заголовком «Фокус завершён». Готово, когда тест зелёный.
3. (*) Сделайте `CachingTaskRepository` — декоратор, который читает задачи из обёрнутого хранилища только при первом `loadTasks()`, а дальше отдаёт из памяти (и обновляет память при `saveTasks`). Готово, когда тест со шпионом-репозиторием подтверждает: два вызова `loadTasks()` → одно чтение из обёрнутого.
4. (*) Покажите уведомления и в активном приложении: реализуйте `UNUserNotificationCenterDelegate` с методом `userNotificationCenter(_:willPresent:withCompletionHandler:)`. Подумайте, в каком слое ему место и кто должен держать на него сильную ссылку.

---

## Урок 12. Статистика: Charts, Template Method, окна

Сделаем отдельное окно статистики: график минут фокуса по дням и экспорт истории в CSV или Markdown. Здесь появятся второе окно, Swift Charts, кусочек AppKit и паттерн Template Method.

### Расчёт по дням — чистая функция

Логика статистики не должна зависеть ни от интерфейса, ни от текущего времени. Поэтому время и календарь — параметры:

```swift
public struct DailyFocus: Identifiable, Equatable, Sendable {
    public let day: Date      // начало суток
    public let minutes: Int
    public var id: Date { day }

    public init(day: Date, minutes: Int) {
        self.day = day
        self.minutes = minutes
    }
}

public enum FocusStatistics {
    /// Минуты фокуса за последние `count` дней, от старых к новым, включая дни без сессий.
    public static func lastDays(
        _ count: Int,
        from sessions: [FocusSession],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [DailyFocus] {
        // практика 1
        []
    }
}
```

Спецификация:

```swift
@Suite("Статистика")
struct StatisticsTests {
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    let now = Date(timeIntervalSince1970: 1_700_000_000)  // 14 ноября 2023, 22:13 UTC

    @Test func lastDaysIncludesEmptyDays() {
        let sessions = [
            FocusSession(taskID: nil, startedAt: now, duration: 25 * 60),
            FocusSession(taskID: nil, startedAt: now.addingTimeInterval(-3600), duration: 25 * 60),
            FocusSession(taskID: nil, startedAt: now.addingTimeInterval(-2 * 86_400), duration: 50 * 60),
        ]
        let days = FocusStatistics.lastDays(3, from: sessions, now: now, calendar: calendar)
        #expect(days.map(\.minutes) == [50, 0, 50])
        #expect(days.last?.day == calendar.startOfDay(for: now))
    }
}
```

> Календарь в тесте явно настроен на UTC. С `Calendar.current` тест зависел бы от часового пояса компьютера и мог бы падать у вас и проходить у другого. Время, календарь, локаль, случайные числа — такие же зависимости, как репозиторий, и их тоже внедряют.

### Второе окно и график

Добавьте в `FocuslyApp` вторую сцену:

```swift
Window("Статистика", id: "statistics") {
    StatisticsView()
        .withDependencies(deps)
}
```

`Window` — окно в единственном экземпляре (в отличие от `WindowGroup`). Открыть его можно из любой View:

```swift
@Environment(\.openWindow) private var openWindow
// ...
Button("Статистика", systemImage: "chart.bar") {
    openWindow(id: "statistics")
}
```

График — модуль Charts:

```swift
import Charts
import FocuslyCore
import SwiftUI

struct StatisticsView: View {
    @Environment(SessionLog.self) private var log

    var body: some View {
        let days = FocusStatistics.lastDays(7, from: log.sessions)
        Chart(days) { day in
            BarMark(
                x: .value("День", day.day, unit: .day),
                y: .value("Минуты", day.minutes)
            )
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .frame(minWidth: 480, minHeight: 240)
        .padding()
    }
}
```

`Chart` принимает коллекцию `Identifiable` и для каждого элемента рисует метку (`BarMark`, `LineMark`, `PointMark`…). `.value("Подпись", значение)` связывает поле данных с осью.

### Экспорт: Template Method

Отчёт в CSV и в Markdown строится одинаково: заголовок → по строке на сессию → итог. Различаются только детали. Зафиксируем **алгоритм** в расширении протокола, а детали оставим реализациям:

```swift
public protocol SessionReportFormat {
    var fileExtension: String { get }
    func header() -> String
    func row(for session: FocusSession, taskTitle: String) -> String
    func footer(totalMinutes: Int) -> String?
}

extension SessionReportFormat {
    // «Крючок» с реализацией по умолчанию: итог не обязателен.
    public func footer(totalMinutes: Int) -> String? { nil }

    // Шаблонный метод: общий алгоритм, который нельзя переопределить.
    public func render(_ sessions: [FocusSession], taskTitles: [UUID: String]) -> String {
        var lines = [header()]
        for session in sessions.sorted(by: { $0.startedAt < $1.startedAt }) {
            let title = session.taskID.flatMap { taskTitles[$0] } ?? "Без задачи"
            lines.append(row(for: session, taskTitle: title))
        }
        let totalMinutes = Int(sessions.reduce(0) { $0 + $1.duration } / 60)
        if let footer = footer(totalMinutes: totalMinutes) {
            lines.append(footer)
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

public struct MarkdownReportFormat: SessionReportFormat {
    public init() {}
    public var fileExtension: String { "md" }
    public func header() -> String { "| Дата | Задача | Минуты |\n|---|---|---|" }
    public func row(for session: FocusSession, taskTitle: String) -> String {
        "| \(session.startedAt.formatted(.iso8601)) | \(taskTitle) | \(Int(session.duration / 60)) |"
    }
    public func footer(totalMinutes: Int) -> String? { "\n**Итого: \(totalMinutes) мин**" }
}

// CSVReportFormat — практика 2
```

> **🧩 Паттерн: Template Method (Шаблонный метод).** Скелет алгоритма определён в одном месте, а отдельные шаги переопределяют наследники. В классическом ООП это абстрактный базовый класс с `final`-методом-шаблоном и абстрактными шагами. В Swift — протокол (шаги) плюс расширение (шаблон и шаги по умолчанию). Структуры не наследуются, но паттерн работает.

> **Ловушка: статическая и динамическая диспетчеризация.** `footer` объявлен **в протоколе**, поэтому `render` вызывает версию конкретного типа (у Markdown — свою). А если бы `footer` был только в расширении, а не в протоколе, `render` всегда вызывал бы версию из расширения, даже когда у `MarkdownReportFormat` есть свой `footer`. Компилятор не предупредит. Правило: всё, что реализации должны иметь возможность переопределить, объявляйте в самом протоколе.

### Сохранение файла: немного AppKit

SwiftUI покрывает не всё, и на macOS нормально использовать AppKit напрямую. Окно сохранения файла:

```swift
import AppKit

private func export(_ text: String, fileExtension: String) {
    let panel = NSSavePanel()
    panel.nameFieldStringValue = "focus-report.\(fileExtension)"
    guard panel.runModal() == .OK, let url = panel.url else { return }
    try? text.write(to: url, atomically: true, encoding: .utf8)
}
```

> **Песочница.** Без разрешения приложение не может писать даже в файл, который пользователь сам выбрал. Включите: таргет **Focusly → Signing & Capabilities → App Sandbox → File Access → User Selected File → Read/Write**. Иначе запись молча не сработает (ошибку глушит `try?`; попробуйте заменить его на `do/catch` и посмотреть, что за ошибка).

Выбор формата — `Picker` по маленькому `enum` в приложении, у которого есть свойство `format: any SessionReportFormat`. Названия задач для отчёта берите из `TaskListViewModel`.

Подробнее: [Swift Charts](https://developer.apple.com/documentation/charts), [Template Method](https://refactoring.guru/ru/design-patterns/template-method), [Bring multiple windows to your SwiftUI app (WWDC22)](https://developer.apple.com/videos/play/wwdc2022/10061/), [NSSavePanel](https://developer.apple.com/documentation/appkit/nssavepanel)

### Готово, когда

- окно статистики открывается кнопкой и показывает 7 столбцов;
- экспорт сохраняет файл в выбранном формате;
- тесты статистики и форматов зелёные.

### Практика

1. Реализуйте `lastDays`. Готово, когда тест выше зелёный.
   <details><summary>Подсказка</summary><code>calendar.startOfDay(for:)</code>, <code>calendar.date(byAdding: .day, value: -n, to:)</code>, <code>calendar.isDate(_:inSameDayAs:)</code>. Перебирайте смещения от <code>count - 1</code> до <code>0</code>.</details>
2. Напишите `CSVReportFormat` (заголовок `date,task,minutes`, без итога). Название задачи может содержать запятые и кавычки: оберните его в кавычки, а кавычки внутри удвойте. Готово, когда тест на название `Сказать "привет"` даёт `…,"Сказать ""привет""",25`.
3. (*) Добавьте формат JSON. Готово, когда для этого понадобилось написать одну новую структуру и добавить один вариант в `enum` выбора формата, не трогая `render` и окно статистики. Подумайте, удобно ли JSON ложится в шаблон «заголовок → строки → итог», и если нет, что это говорит о границах паттерна.

---

## Урок 13. Строка меню, настройки, отладка

Последние штрихи настоящего Mac-приложения: таймер в строке меню, окно настроек по **⌘,** и несколько приёмов отладки.

### Таймер в строке меню

```swift
MenuBarExtra {
    TimerView()
        .padding()
        .frame(width: 280)
        .withDependencies(deps)
} label: {
    MenuBarLabel(timer: deps.timer)
}
.menuBarExtraStyle(.window)
```

```swift
struct MenuBarLabel: View {
    let timer: FocusTimerViewModel

    var body: some View {
        if timer.isRunning {
            Text(timer.remainingText)
        } else {
            Image(systemName: "timer")
        }
    }
}
```

- `MenuBarExtra` — сцена «значок в строке меню». `.menuBarExtraStyle(.window)` показывает по щелчку не обычное меню, а маленькое окно с любым SwiftUI-содержимым.
- В строке меню и в главном окне — **один и тот же** объект таймера из `AppDependencies`. Запустите таймер в окне — он идёт и в строке меню, поставьте на паузу из строки меню — окно тоже это покажет.

> **🧩 Принцип: единый источник истины (Single Source of Truth).** У каждого кусочка данных один владелец, а все экраны смотрят на него. Мы пришли к этому не случайно: composition root (урок 7) создаёт объекты один раз, Observer (урок 4) сам обновляет все View, которые их читают. Попробуйте мысленно сделать то же самое с `@State` внутри каждой View: таймеров стало бы два, и они бы расходились.

### Настройки

Сцена `Settings` даёт окно настроек и пункт меню **Focusly → Настройки…** (⌘,) бесплатно:

```swift
Settings {
    SettingsView()
        .withDependencies(deps)
}
```

Настройки таймера хранятся в `UserDefaults`. По уже знакомой схеме: протокол в ядре, реализация с системным API, реализация в памяти для тестов.

```swift
public protocol SettingsStore {
    func load() -> PomodoroSettings
    func save(_ settings: PomodoroSettings)
}
// UserDefaultsSettingsStore (JSON в UserDefaults по ключу) и InMemorySettingsStore — практика 1
```

`FocusTimerViewModel` получает `settingsStore` в `init` (вместо готовых `settings`) и открывает настройки как вычисляемое свойство с записью:

```swift
public var settings: PomodoroSettings {
    get { timer.settings }
    set {
        timer.apply(newValue)       // новый метод автомата: обновить настройки
        settingsStore.save(newValue)
    }
}
```

Метод `apply(_:)` в `PomodoroTimer` меняет настройки и, если таймер стоит (`idle`), пересчитывает `remainingSeconds` под новую длительность фазы. Запущенный отсчёт он не трогает.

```swift
struct SettingsView: View {
    @Environment(FocusTimerViewModel.self) private var timer

    var body: some View {
        @Bindable var timer = timer
        Form {
            Stepper("Фокус: \(timer.settings.focusMinutes) мин",
                    value: $timer.settings.focusMinutes, in: 1...90)
            Stepper("Короткий перерыв: \(timer.settings.shortBreakMinutes) мин",
                    value: $timer.settings.shortBreakMinutes, in: 1...30)
            Stepper("Длинный перерыв: \(timer.settings.longBreakMinutes) мин",
                    value: $timer.settings.longBreakMinutes, in: 1...60)
            Stepper("Длинный перерыв каждые \(timer.settings.sessionsBeforeLongBreak)",
                    value: $timer.settings.sessionsBeforeLongBreak, in: 2...8)
        }
        .padding()
        .frame(width: 360)
    }
}
```

`$timer.settings.focusMinutes` — привязка «вглубь»: каждое изменение степпера вызывает сеттер `settings`, и настройки сохраняются.

> Для простых флагов интерфейса SwiftUI предлагает `@AppStorage("key")` — `@State`, который сам живёт в `UserDefaults`. Он удобен для мелочей прямо во View («показывать выполненные»), но для настроек, которые нужны логике и тестам, протокол `SettingsStore` лучше: ViewModel не знает про `UserDefaults`, а тесты не пишут в настоящие настройки.

### Отладка: короткий набор приёмов

| Задача | Инструмент |
|---|---|
| остановиться на строке | точка останова: щелчок по номеру строки в Xcode, затем ⌘R |
| посмотреть значение в остановке | `po выражение` или `p выражение` в консоли отладчика |
| остановиться только при условии | правый щелчок по точке останова → Edit Breakpoint → Condition |
| почему перерисовалась View | `let _ = Self._printChanges()` в начале `body` (урок 4) |
| что делает хранилище | `log stream --predicate 'subsystem == "Focusly"' --level debug` (урок 11) |
| где тормозит интерфейс | Product → Profile (⌘I) → шаблон SwiftUI или Time Profiler |
| утечки памяти | Debug Memory Graph (кнопка с тремя кружками на панели отладки) — ищите `FocusTimerViewModel` в двух экземплярах |

Подробнее: [MenuBarExtra](https://developer.apple.com/documentation/swiftui/menubarextra), [Settings](https://developer.apple.com/documentation/swiftui/settings)

### Готово, когда

- значок в строке меню показывает остаток времени и управляет тем же таймером;
- окно настроек открывается по ⌘, и изменения переживают перезапуск;
- `./scripts/check.sh` зелёный, `/mentor-review` не находит 🔴.

### Практика

1. Реализуйте `UserDefaultsSettingsStore`, `InMemorySettingsStore` и `apply(_:)` с тестами: изменение настроек в состоянии `idle` меняет `remainingSeconds`, а в `running` — нет. Готово, когда настройки сохраняются после перезапуска.
   <details><summary>Подсказка</summary>Структура уже <code>Codable</code>: <code>JSONEncoder().encode(settings)</code> → <code>defaults.set(data, forKey:)</code>. В тестах можно создать отдельный <code>UserDefaults(suiteName:)</code>, чтобы не трогать настоящие настройки.</details>
2. Сделайте иконку приложения (Assets → AppIcon) и проверьте, как приложение выглядит в Dock, в ⌘Tab и в Finder. Готово, когда у приложения своя иконка.
3. (*) Добавьте в настройки переключатель «Только в строке меню»: приложение пропадает из Dock и ⌘Tab, остаётся только значок. Готово, когда переключение работает без перезапуска.
   <details><summary>Подсказка</summary><code>NSApplication.shared.setActivationPolicy(.accessory)</code> и <code>.regular</code>.</details>

---

# Итог: проект целиком

Если вы прошли все уроки, структура проекта примерно такая:

```
vspomnit/
├── FocuslyCore/
│   ├── Package.swift
│   ├── Sources/FocuslyCore/
│   │   ├── FocusTask.swift            модель (Value Object)
│   │   ├── Timer.swift                TimerPhase, PomodoroSettings, FocusSession, PomodoroTimer (State)
│   │   ├── TaskListViewModel.swift    MVVM, Observer, Delegate
│   │   ├── FocusTimerViewModel.swift  MVVM, Task
│   │   ├── SessionLog.swift
│   │   ├── Repositories.swift         Repository, JSONFileStore<T>, Decorator
│   │   ├── Sorting.swift              TaskFilter (enum), TaskSortStrategy (Strategy)
│   │   ├── Commands.swift             Command, CommandHistory
│   │   ├── Notifier.swift             Adapter, Null Object
│   │   ├── SettingsStore.swift
│   │   └── Reports.swift              Template Method, FocusStatistics
│   └── Tests/FocuslyCoreTests/        ~35 тестов
└── Focusly/Focusly/
    ├── FocuslyApp.swift               сцены: WindowGroup, Window, MenuBarExtra, Settings
    ├── AppDependencies.swift          Composition Root, Factory Method
    ├── TaskCommands.swift             меню
    └── Views/                         ContentView, SidebarView, TaskListView, TaskRow,
                                       TaskDetailView, TimerView, StatisticsView, SettingsView
```

Кто от кого зависит (стрелка — «знает о»):

```
                    ┌──────────────────── Focusly (приложение) ─────────────────────┐
                    │  FocuslyApp ──▶ AppDependencies ──▶ конкретные реализации     │
                    │       │              (live / preview)                         │
                    │       ▼                                                       │
                    │     Views ──@Environment──▶ ViewModel'и                       │
                    └───────────────────────────────┬───────────────────────────────┘
                                                    ▼
┌─────────────────────────────── FocuslyCore (ядро) ────────────────────────────────┐
│  TaskListViewModel ──▶ TaskRepository ◀── JSONFile / InMemory / Logging(...)       │
│        ▲  │                                                                        │
│ delegate  └──▶ TaskSortStrategy, TaskCommand, CommandHistory, FocusTask            │
│        │                                                                           │
│  FocusTimerViewModel ──▶ PomodoroTimer, SessionLog ──▶ SessionRepository           │
│                     └──▶ Notifier ◀── UserNotifications / Silent                    │
│                     └──▶ SettingsStore ◀── UserDefaults / InMemory                  │
└────────────────────────────────────────────────────────────────────────────────────┘
```

Обратите внимание: ни одна стрелка не идёт из ядра в приложение, а ViewModel'и указывают только на протоколы.

**Паттерны и принципы курса:**

| Паттерн / принцип | Где в Focusly | Какую проблему решает | Урок |
|---|---|---|---|
| Слоистая архитектура | пакет `FocuslyCore` отдельно от приложения | логика не зависит от интерфейса, тестируется быстро | 0 |
| Composite, Builder | дерево View, `@ViewBuilder` | одинаковая работа с простыми и составными элементами | 1 |
| Инкапсуляция, Value Object | `FocusTask`: `let`, `private(set)`, `init` | нельзя нарушить инварианты, безопасно копировать | 2 |
| MVVM, SRP | `TaskListViewModel`, `FocusTimerViewModel` | логика отделена от отображения | 4 |
| Observer | `@Observable` | интерфейс сам обновляется при изменении данных | 4 |
| Repository, DIP | `TaskRepository`, `SessionRepository` | ViewModel не знает, где хранятся данные | 5 |
| Композиция, дженерики, LSP | `JSONFileStore<T>`, контрактные тесты | переиспользование без наследования; реализации взаимозаменяемы | 6 |
| DI, Composition Root, Factory Method | `AppDependencies.live()` / `.preview()` | все объекты собираются в одном месте; тестовые данные для превью | 7 |
| Strategy, OCP | `TaskSortStrategy` | новые сортировки без правки ViewModel | 8 |
| State (конечный автомат) | `PomodoroTimer` | поведение зависит от состояния, переходы явны и проверены | 9 |
| Delegate | `FocusTimerDelegate` | таймер сообщает о событии, не завися от списка задач | 9 |
| Command (+ Memento для сравнения) | `TaskCommand`, `CommandHistory` | отмена и повтор действий | 10 |
| Decorator | `LoggingTaskRepository` | новое поведение без правки и без наследования | 11 |
| Adapter, Null Object | `UserNotificationsNotifier`, `SilentNotifier` | чужой API под свой интерфейс; «ничего не делать» без `nil` | 11 |
| Template Method | `SessionReportFormat.render` | общий алгоритм, разные шаги | 12 |
| Single Source of Truth | один таймер для окна, строки меню и настроек | экраны не расходятся | 13 |

---

# Финальное задание

Напишите с нуля второе приложение — **Shelf**, домашнюю библиотеку книг. Новый Xcode-проект и новый пакет ядра; код Focusly не копировать (подглядывать можно).

Требования:

1. Книга: название, автор, статус (`хочу прочитать` / `читаю` / `прочитана`), оценка 1–5 (необязательна), дата добавления. Инварианты защищены инкапсуляцией.
2. Окно в три колонки: статусы в боковой панели, список книг, карточка книги с редактированием.
3. Поиск по названию и автору; минимум три сортировки, подключённые как стратегии.
4. Хранение в JSON через репозиторий; контрактные тесты для двух реализаций.
5. Отмена и повтор добавления, удаления и изменения книги по ⌘Z / ⇧⌘Z.
6. Таймер чтения в строке меню: «читаю 30 минут» с паузой; по окончании минуты чтения записываются книге. Логика таймера — конечный автомат с тестами.
7. Окно статистики: прочитано книг по месяцам за год (график), экспорт списка в два формата через Template Method.
8. Импорт книг из CSV-файла (`NSOpenPanel`) через отдельный тип-импортёр за протоколом.
9. Composition root с `live()` и `preview()`; ни одна View не создаёт зависимости сама.
10. Не меньше 25 тестов в ядре, `swift format lint` без замечаний.

Готово, когда `/mentor-review` по всему проекту не находит 🔴, а вы можете для каждого паттерна из таблицы выше показать, где он у вас и что сломалось бы без него.

---

# Шпаргалка

**Проверка и запуск**

```bash
./scripts/check.sh            # всё
./scripts/check.sh core       # ядро: build + test
./scripts/check.sh test Timer # тесты по имени
./scripts/check.sh app        # сборка приложения
./scripts/run.sh              # собрать и запустить
swift format -i <файл>        # отформатировать файл
log stream --predicate 'subsystem == "Focusly"' --level debug
```

**Наставник:** `/lesson`, `/check`, `/hint …`, `/mentor-review`, `/explain …`. Выключить режим: `touch .claude/mentor-off`.

**Обёртки свойств SwiftUI**

| Обёртка | Владеет | Для чего |
|---|---|---|
| `@State` | View | локальное значение или `@Observable`-объект, которым владеет View |
| `@Binding` | кто-то выше | изменять чужое значение |
| `@Bindable` | кто-то выше | получить `$obj.prop` у `@Observable`-объекта |
| `@Environment(T.self)` | окружение | достать объект, положенный через `.environment(obj)` |
| `@Environment(\.key)` | система | `openWindow`, `undoManager`, `colorScheme`, `dismiss` |
| `@AppStorage("key")` | `UserDefaults` | простые настройки интерфейса |

**Сцены macOS**

| Сцена | Что это |
|---|---|
| `WindowGroup` | обычное окно, можно открыть несколько (⌘N) |
| `Window(_:id:)` | единственное окно, открывается через `openWindow(id:)` |
| `Settings` | окно настроек, пункт меню ⌘, |
| `MenuBarExtra` | значок в строке меню; `.menuBarExtraStyle(.window)` — с окном |
| `.commands { }` | пункты меню: `CommandMenu`, `CommandGroup(replacing:/before:/after:)` |

**Swift Testing**

```swift
@Suite("Имя") struct Tests { }            // группа
@Test func name() { }                     // тест
@Test(arguments: [1, 2, 3]) func f(_ x: Int) { }  // параметризованный
#expect(a == b)                           // проверка
let x = try #require(optional)            // проверка с остановкой
#expect(throws: SomeError.self) { try f() }
@MainActor @Suite struct VMTests { }      // тесты @MainActor-типов
```

**ООП и SOLID в одну строку**

| Принцип | Суть | В Focusly |
|---|---|---|
| Инкапсуляция | инварианты нельзя нарушить снаружи | `private(set) var completedPomodoros` |
| Полиморфизм | один вызов — разное поведение | `repository.saveTasks` для JSON/InMemory/Logging |
| Композиция > наследование | собирать из частей, а не наследовать | `JSONFileTaskRepository` содержит `JSONFileStore` |
| S — единственная ответственность | одна причина для изменения | View рисует, ViewModel решает, Repository хранит |
| O — открытость/закрытость | расширять без правок | новая `TaskSortStrategy` |
| L — подстановка Лисков | любая реализация протокола подходит | контрактные тесты |
| I — разделение интерфейсов | маленькие протоколы | `Notifier` из двух методов, а не «UNUserNotificationCenter целиком» |
| D — инверсия зависимостей | зависеть от абстракций | ViewModel знает `any TaskRepository` |

---

# Источники и что почитать дальше

**Официальная документация**

- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui) — пошаговые уроки Apple, хорошо дополняют части I–II.
- [SwiftUI](https://developer.apple.com/documentation/swiftui) — справочник; начинайте с разделов [App organization](https://developer.apple.com/documentation/swiftui/app-organization) и [Model data](https://developer.apple.com/documentation/swiftui/model-data).
- [Migrating from ObservableObject to @Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro) — если попадётся старый код с `@Published` и `@StateObject`.
- [Observation](https://developer.apple.com/documentation/observation) — как устроен `@Observable`.
- [Swift Testing](https://developer.apple.com/documentation/testing) — всё про `@Test`, `#expect`, параметризацию.
- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/) — разделы Protocols, Generics, Access Control, Concurrency, ARC.
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) — как называть типы и методы «по-свифтовому».
- [Swift 6 Migration Guide](https://www.swift.org/migration/documentation/migrationguide/) — подробно про строгую конкурентность, акторы и `Sendable`.

**Видео WWDC**

- [Data Essentials in SwiftUI (WWDC20)](https://developer.apple.com/videos/play/wwdc2020/10040/) — источник истины, `@State` и `@Binding`.
- [Demystify SwiftUI (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10022/) — идентичность, время жизни и зависимости View.
- [Discover Observation in SwiftUI (WWDC23)](https://developer.apple.com/videos/play/wwdc2023/10149/) — `@Observable`.
- [Meet Swift Testing (WWDC24)](https://developer.apple.com/videos/play/wwdc2024/10179/).
- [Protocol-Oriented Programming in Swift (WWDC15)](https://developer.apple.com/videos/play/wwdc2015/408/) — классика о протоколах вместо наследования.

**Книги**

- Gamma, Helm, Johnson, Vlissides. *Design Patterns: Elements of Reusable Object-Oriented Software* (GoF, «Приёмы объектно-ориентированного проектирования») — первоисточник паттернов. Примеры на C++, но идеи переносятся.
- Freeman, Robson. *Head First Design Patterns* («Паттерны проектирования») — самое понятное введение в паттерны, если GoF тяжело.
- Chris Eidhof, Florian Kugler. [*Thinking in SwiftUI*](https://www.objc.io/books/thinking-in-swiftui/) — как SwiftUI устроен внутри: раскладка, состояние, идентичность.
- Paul Hudson. [*Hacking with macOS*](https://www.hackingwithswift.com/store/hacking-with-macos) — много небольших Mac-проектов на SwiftUI и AppKit.

**Статьи**

- [Каталог паттернов на refactoring.guru](https://refactoring.guru/ru/design-patterns/catalog) — каждый паттерн с картинками и [примерами на Swift](https://refactoring.guru/ru/design-patterns/swift). Читайте после урока, где паттерн появился.
- [Запахи кода (refactoring.guru)](https://refactoring.guru/ru/refactoring/smells) — как распознать, что код пора разделять.
- Martin Fowler. [Inversion of Control Containers and the Dependency Injection pattern](https://martinfowler.com/articles/injection.html) — откуда пошло DI.
- Mark Seemann. [Composition Root](https://blog.ploeh.dk/2011/07/28/CompositionRoot/) — коротко о том, где собирать зависимости.
