package org.github.bootstrap

class Attribute {

	private final static String QUOTE = "\"";
	private final static String SPACE = " ";
	private final static String EQUALS = "=";
	
	/**
	 * Prints parameters to given output. 
	 */
	static void outputAttributes(def attrs, def writer) {
		attrs.remove('tagName') // Just in case one is left
		attrs.each { k, v ->
			writer << k
			writer << EQUALS << QUOTE 
			writer << v.encodeAsHTML()
			writer << QUOTE
		}
	}
	
	/**
	 * Method taken from Grails standar Form taglib.	
	 */
	static void booleanToAttribute(def attrs, String attrName) {
		def attrValue = attrs.remove(attrName)
		// If the value is the same as the name or if it is a boolean value,
		// reintroduce the attribute to the map according to the w3c rules, so it is output later
		if (Boolean.valueOf(attrValue) ||
		   (attrValue instanceof String && attrValue?.equalsIgnoreCase(attrName))) {
			attrs.put(attrName, attrName)
		} else if (attrValue instanceof String && !attrValue?.equalsIgnoreCase('false')) {
			// If the value is not the string 'false', then we should just pass it on to
			// keep compatibility with existing code
			attrs.put(attrName, attrValue)
		}
	}
}
