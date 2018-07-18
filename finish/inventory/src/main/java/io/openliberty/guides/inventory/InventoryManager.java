//tag::copyright[]
/*******************************************************************************
* Copyright (c) 2017, 2018 IBM Corporation and others.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*     IBM Corporation - Initial implementation
*******************************************************************************/
//end::copyright[]
package io.openliberty.guides.inventory;

import java.util.Properties;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import io.openliberty.guides.inventory.client.SystemClient;
import io.openliberty.guides.inventory.model.*;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

@ApplicationScoped
public class InventoryManager {

    private List<SystemData> systems = Collections.synchronizedList(new ArrayList<>());
    private SystemClient systemClient = new SystemClient();

    public Properties get(String hostname) {
        systemClient.init(hostname, 9080);
        return systemClient.getProperties();
    }

    public void add(String hostname, Properties systemProps) {
        Properties props = new Properties();
        props.setProperty("os.name", systemProps.getProperty("os.name"));
        props.setProperty("user.name", systemProps.getProperty("user.name"));

        SystemData host = new SystemData(hostname, props);
        if (!systems.contains(host))
            systems.add(host);
    }

    public InventoryList list() {
        return new InventoryList(systems);
    }
}
