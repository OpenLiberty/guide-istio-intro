// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2019, 2022 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License 2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-2.0/
 *
 * SPDX-License-Identifier: EPL-2.0
 *******************************************************************************/
// end::copyright[]
package it.io.openliberty.guides.system;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLSession;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import jakarta.ws.rs.client.WebTarget;
import jakarta.ws.rs.core.Response;

import io.openliberty.guides.system.SystemResource;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.TestMethodOrder;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.AfterEach;

@TestMethodOrder(OrderAnnotation.class)
public class SystemEndpointIT {

    private static String clusterUrl;

    private Client client;
    private Response response;

    @BeforeAll
    public static void oneTimeSetup() {
        // Allows for overriding the "Host" http header
        System.setProperty("sun.net.http.allowRestrictedHeaders", "true");

        String clusterIp = System.getProperty("cluster.ip");
        String nodePort = System.getProperty("port");

        clusterUrl = "http://" + clusterIp + ":" + nodePort + "/system/properties/";
    }

    @BeforeEach
    public void setup() {
        response = null;
        client = ClientBuilder.newBuilder()
                    .hostnameVerifier(new HostnameVerifier() {
                        public boolean verify(String hostname, SSLSession session) {
                            return true;
                        }
                    })
                    .build();
    }

    @AfterEach
    public void teardown() {
        client.close();
    }

    @Test
    @Order(1)
    public void testPodNameNotNull() {
        response = this.getResponse(clusterUrl);
        this.assertResponse(clusterUrl, response);
        String greeting = response.getHeaderString("X-Pod-Name");

        String message = "Container name should not be null but it was. "
            + "The service is probably not running inside a container";

        assertNotNull(greeting, message);
    }

    @Test
    @Order(2)
    // tag::testAppVersion[]
    public void testAppVersion() {
        response = this.getResponse(clusterUrl);

        String expectedVersion = SystemResource.appVersion;
        String actualVersion = response.getHeaderString("X-App-Version");

        assertEquals(expectedVersion, actualVersion);
    }
    // end::testAppVersion[]

    @Test
    @Order(3)
    public void testGetProperties() {
        Client client = ClientBuilder.newClient();

        WebTarget target = client.target(clusterUrl);
        Response response = target
            .request()
            .header("Host", System.getProperty("host-header"))
            .get();

        assertEquals(200, response.getStatus(),
            "Incorrect response code from " + clusterUrl);

        response.close();
    }

    private Response getResponse(String url) {
        return client
            .target(url)
            .request()
            .header("Host", System.getProperty("host-header"))
            .get();
    }

    private void assertResponse(String url, Response response) {
        assertEquals(200, response.getStatus(),
            "Incorrect response code from " + url);
    }

}
