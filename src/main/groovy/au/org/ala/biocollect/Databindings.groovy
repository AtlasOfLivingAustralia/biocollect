package au.org.ala.biocollect

class Databindings /*extends AttributeMap*/ {
    protected final static String QUOTE = "\""
    protected final static String SPACE = " "
    protected final static String EQUALS = "="
    protected final static String COMMA = ","
    protected final static String COLON = ":"
    private map = [:]
    protected separator = COMMA

    def getMap() { return map }

    def add(key, value) {
        if (map.containsKey(key)) {
            map[key] = map[key] + separator + value
        } else {
            map[key] = value
        }
    }

    def addClass(value) {
        if (value) {
            add('class', value)
        }
    }

    String toString() {
        map.collect({k,v -> k + COLON + v}).join ','
    }
}
