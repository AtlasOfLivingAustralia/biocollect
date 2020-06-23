package au.org.ala.biocollect

import com.vividsolutions.jts.geom.Geometry
import grails.converters.JSON
import org.geotools.geojson.geom.GeometryJSON

class GeometryUtils {

    static Geometry geoJsonMapToGeometry(Map geoJson) {
        String json = (geoJson as JSON).toString()
        new GeometryJSON().read(json)
    }

    static boolean doShapesIntersect(Map shapeA, Map shapeB) {
        Geometry shapeAGeom = geoJsonMapToGeometry(shapeA)
        Geometry shapeBGeom = geoJsonMapToGeometry(shapeB)
        shapeAGeom?.intersects(shapeBGeom)
    }
}
