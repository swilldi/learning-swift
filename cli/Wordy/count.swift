let text = """
Swift is a general purpose language. Swift is fast, \
and Swift is safe. Fast code is good code.
"""

let words = text
    .lowercased()
    .split { !$0.isLetter }
    .map(String.init)

var counts = [String: Int]()
for word in words {
    counts[word, default: 0] += 1
}


let totalWordsCount = counts.values.reduce(0, {$0 + $1})
let uniqueWordsCount = Set(words).count

print("total words count:\t\(totalWordsCount)")
print("unique words count:\t\(uniqueWordsCount)")
for (word, count) in counts.sorted(by: { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }).prefix(5) {
    print("\(word):\t\(count)")
}
