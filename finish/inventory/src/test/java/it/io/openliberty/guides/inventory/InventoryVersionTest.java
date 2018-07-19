// tag::copyright[]
/*******************************************************************************
 * Copyright (c) 2018 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/
// end::copyright[]
package it.io.openliberty.guides.inventory;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import javax.json.JsonObject;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.provider.jsrjsonp.JsrJsonpProvider;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class InventoryVersionTest {

    private static String testIp;
    private static String testPort;
    private static String sysUrl;
    private static String invUrl;

    private Client client;

    private final String SYSTEM_PROPERTIES = "system/properties";
    private final String INVENTORY_SYSTEMS = "inventory/systems";

    // Repeat tests to make sure that routing rules have actually been
    // applied and that the test didn't pass by chance.
    private final int REPETITIONS = 3;

    @BeforeClass
    public static void oneTimeSetup() {
        testIp = System.getProperty("test.ip");
        testPort = System.getProperty("test.port");
        sysUrl = "http://" + testIp + ":" + testPort + "/";
        invUrl = "http://" + testIp + ":" + testPort + "/";
    }

    @Before
    public void setup() {
        client = ClientBuilder.newClient();
        client.register(JsrJsonpProvider.class);
    }

    @After
    public void teardown() {
        client.close();
    }

    @Test
    public void testV1Default() {
        for (int i = 0; i < REPETITIONS; i++) {
            Response response = this.getResponse(invUrl + INVENTORY_SYSTEMS);
            this.assertResponse(invUrl, response);

            JsonObject obj = response.readEntity(JsonObject.class);

            assertTrue("Response does not contain \"total\" property",
                       !obj.isNull("total"));
        }
    }

    @Test
    public void testV1Header() {
        for (int i = 0; i < REPETITIONS; i++) {
            Response response = this.getResponseWithVersion(
                invUrl + INVENTORY_SYSTEMS,
                "v1");

            this.assertResponse(invUrl, response);

            JsonObject obj = response.readEntity(JsonObject.class);

            assertTrue("Response does not contain \"total\" property",
                       !obj.isNull("total"));
        }
    }

    @Test
    public void testV2Header() {
        for (int i = 0; i < REPETITIONS; i++) {
            Response response = this.getResponseWithVersion(
                invUrl + INVENTORY_SYSTEMS,
                "v2");

            this.assertResponse(invUrl, response);

            JsonObject obj = response.readEntity(JsonObject.class);

            assertTrue("Response does not contain \"count\" property",
                       !obj.isNull("count"));
        }
    }

    // tag::doc[]
    /**
     * <p>
     * Returns response information from the specified URL.
     * </p>
     * 
     * @param url
     *          - target URL.
     * @return Response object with the response from the specified URL.
     */
    // end::doc[]
    private Response getResponse(String url) {
        return client.target(url).request().get();
    }

    private Response getResponseWithVersion(String url, String version) {
        return client.target(url).request().header("x-version", version).get();
    }

    // tag::doc[]
    /**
     * <p>
     * Asserts that the given URL has the correct response code of 200.
     * </p>
     * 
     * @param url
     *          - target URL.
     * @param response
     *          - response received from the target URL.
     */
    // end::doc[]
    private void assertResponse(String url, Response response) {
        assertEquals("Incorrect response code from " + url, 200, response.getStatus());
    }
}
