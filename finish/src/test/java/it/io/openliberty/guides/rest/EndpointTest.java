// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2018 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
 // end::copyright[]
package it.io.openliberty.guides.rest;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

import javax.json.JsonObject;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.provider.jsrjsonp.JsrJsonpProvider;

public class EndpointTest {

    @Test
    public void testGetGreeting() {
        // Allows for overriding the "Host" http header
        System.setProperty("sun.net.http.allowRestrictedHeaders", "true");

        String hostname = System.getProperty("cluster.ip");
        String port = System.getProperty("port");
        String url = String.format("http://%s:%s/hello", hostname, port);

        Client client = ClientBuilder.newClient();
        client.register(JsrJsonpProvider.class);

        WebTarget target = client.target(url);
        Response response = target
            .request()
            .header("Host", System.getProperty("host-header"))
            .get();

        assertEquals("Incorrect response code from " + url,
                     200,
                     response.getStatus());

        JsonObject obj = response.readEntity(JsonObject.class);
        assertEquals("The greeting property must have message \"hello\"",
                     "hello",
                     obj.getString("greeting"));

        assertEquals("The version must match the pom.xml file",
                     System.getProperty("app.name"),
                     obj.getString("version"));

        response.close();
    }
}
