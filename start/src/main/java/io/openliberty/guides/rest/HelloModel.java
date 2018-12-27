// tag::comment[]
/*******************************************************************************
 * Copyright (c) 2017 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
 // end::comment[]
 package io.openliberty.guides.rest;

public class HelloModel {
    private static final String VERSION = System.getProperty("app.version");
    private String greeting;

    public HelloModel(String greeting) {
        this.greeting = greeting;
    }

    public String getVersion() {
        return VERSION;
    }

    public String getGreeting() {
        return greeting;
    }
}
