package au.org.ala.biocollect;

import au.org.ala.ws.security.AlaWsSecurityConfiguration;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import org.pac4j.oidc.config.OidcConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class IntegrationTestConfiguration extends AlaWsSecurityConfiguration {
    @Bean
    JWKSource<SecurityContext> jwkSource(OidcConfiguration oidcConfiguration) {
        return new ImmutableJWKSet(new JWKSet());
    }
}
