@echo off

set LIVE_DEPLOYMENT=%1
goto :START


:BLUE_DEPLOYMENT
set WEIGHT_BLUE=100
set WEIGHT_GREEN=0
set TEST_WEIGHT_BLUE=0
set TEST_WEIGHT_GREEN=100
echo Setting blue as live...
goto DEPLOY

:GREEN_DEPLOYMENT
set WEIGHT_BLUE=0
set WEIGHT_GREEN=100
set TEST_WEIGHT_BLUE=100
set TEST_WEIGHT_GREEN=0
echo Setting green as live...

:DEPLOY
(
echo apiVersion: networking.istio.io/v1alpha3
echo kind: VirtualService
echo metadata:
echo  name: hello-virtual-service
echo spec:
echo   hosts:
echo   - "example.com"
echo   gateways:
echo  - hello-gateway
echo  http:
echo  - route:
echo    - destination:
echo        port:
echo          number: 9080
echo        host: hello-service
echo        subset: blue
echo      weight: %WEIGHT_BLUE%
echo    - destination:
echo        port:
echo          number: 9080
echo        host: hello-service
echo        subset: green
echo      weight: %WEIGHT_GREEN%
echo ---
echo apiVersion: networking.istio.io/v1alpha3
echo kind: VirtualService
echo metadata:
echo  name: hello-test-virtual-service
echo spec:
echo  hosts:
echo  - "test.example.com"
echo  gateways:
echo  - hello-gateway
echo  http:
echo  - route:
echo    - destination:
echo        port:
echo          number: 9080
echo        host: hello-service
echo        subset: blue
echo      weight: %TEST_WEIGHT_BLUE%
echo    - destination:
echo        port:
echo          number: 9080
echo        host: hello-service
echo        subset: green
echo      weight: %TEST_WEIGHT_GREEN%
echo ---
echo apiVersion: networking.istio.io/v1alpha3
echo kind: DestinationRule
echo metadata:
echo  name: hello-destination-rule
echo spec:
echo  host: hello-service
echo  subsets:
echo  - name: blue
echo    labels:
echo      version: blue
echo  - name: green
echo    labels:
echo      version: green
)> tmp-traffic.yaml

kubectl apply -f tmp-traffic.yaml
del tmp-traffic.yaml
exit /B

:START
if "%LIVE_DEPLOYMENT%"=="blue" goto BLUE_DEPLOYMENT
if "%LIVE_DEPLOYMENT%"=="green" goto GREEN_DEPLOYMENT

echo %LIVE_DEPLOYMENT% is an invalid option
exit /B 1
