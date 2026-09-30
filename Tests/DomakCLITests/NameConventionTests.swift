import Testing
@testable import DomakCLI

@Suite("NameConvention")
struct NameConventionTests {

    @Test("splits on separators and lower-to-upper boundaries", arguments: [
        ("order-context", ["order", "context"]),
        ("order_context", ["order", "context"]),
        ("OrderContext", ["Order", "Context"]),
        ("order context", ["order", "context"]),
        ("orderContext", ["order", "Context"]),
        // A digit resets the lower/upper boundary tracking, so the following
        // uppercase letter doesn't start a new word — documented, not ideal.
        ("order2Context", ["order2Context"]),
    ])
    func wordsFrom(input: String, expected: [String]) {
        #expect(NameConvention.words(from: input) == expected)
    }

    @Test("input with no letters or numbers produces no words")
    func wordsFromEmpty() {
        #expect(NameConvention.words(from: "---") == [])
    }

    @Test("pascalCase capitalizes each word and joins them")
    func pascalCase() {
        #expect(NameConvention.pascalCase(from: "order-context") == "OrderContext")
    }

    @Test("camelCase lowercases only the first character")
    func camelCase() {
        #expect(NameConvention.camelCase(from: "order-context") == "orderContext")
    }

    @Test("defaultAggregateWords drops a trailing Context word")
    func defaultAggregateWordsDropsContext() {
        let words = NameConvention.words(from: "OrderContext")
        #expect(NameConvention.defaultAggregateWords(fromProjectWords: words) == ["Order"])
    }

    @Test("defaultAggregateWords leaves a single word alone")
    func defaultAggregateWordsSingleWord() {
        let words = NameConvention.words(from: "Context")
        #expect(NameConvention.defaultAggregateWords(fromProjectWords: words) == ["Context"])
    }

    @Test("defaultAggregateWords leaves words without a trailing Context alone")
    func defaultAggregateWordsNoContext() {
        let words = NameConvention.words(from: "OrderBook")
        #expect(NameConvention.defaultAggregateWords(fromProjectWords: words) == ["Order", "Book"])
    }
}
