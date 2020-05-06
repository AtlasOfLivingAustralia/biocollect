package au.org.ala.biocollect.merit

import java.lang.annotation.*

/**
 * Annotation to check if user has "edit" or "admin" permissions
 * for a given controller method
 *
 * @author Nick dos Remedios (nick.dosremedios@csiro.au)
 */
@Target([ElementType.TYPE, ElementType.METHOD])
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface PreAuthorise {
    String accessLevel() default "editor" // TODO: change to AccessLevel class from ecodata (shared via webservices somehow)
    String projectIdParam() default "id"
    String redirectController() default "project"
    String redirectAction() default "index"
}
