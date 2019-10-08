package au.org.ala.biocollect

class AttributeMap {
    protected final static String QUOTE = "\""
    protected final static String SPACE = " "
    protected final static String EQUALS = "="
    protected final static String COMMA = ","
    protected final static String COLON = ":"
    private map = [:]
    protected separator = SPACE

    AttributeMap(String separator) {
        this.separator = separator
    }

    AttributeMap() {
    }

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

    def addSpan(value) {
        if (value && !this.classHasSpan()) {
            add('class', value)
        }
    }

    def removeSpan() {
        if (this.classHasSpan()) {
            List classes = map.class.tokenize(' ');
            List remove = classes.findAll{ it.startsWith('span') }
            classes -= remove;
            map.class = classes.join(separator);
        }
    }

    def classHasSpan() {
        return map.containsKey('class') && map.class.tokenize(' ').any {it.startsWith('span')}
    }

    String toString() {
        def strs = ['']
        map.each { k, v ->
            strs << k + EQUALS + QUOTE + v.encodeAsHTML() + QUOTE
        }
        strs.join separator
    }
}
