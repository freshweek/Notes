# Concept

A **Device Tree(DT)** is a simple tree structure where devices are represented by nodes with their properties.

DT is enabled by setting the `CONFIG_OF` to `Y`.

```c
/* This is a comment */ 
// This is another comment 
node_label: nodename@reg{ 
   string-property = "a string"; 
   string-list = "red fish", "blue fish"; 
   one-int-property = <197>; /* One cell in this property */ 
   int-list-property = <0xbeef 123 0xabcd4>; /*each number(cell)is a                         
 *32 bit integer(uint32).
 *There are 3 cells in  
 *this property 
*/                                             
    mixed-list-property = "a string", <0xadbcd45>, <35>, [0x01 0x23 0x45] 
    byte-array-property = [0x01 0x23 0x45 0x67]; 
    boolean-property; 
}; 
```

### Naming Convention

Every node is named in the form `<label>: <name>[@address]`, `<name>` is up to 31 characters in length.


## 

## Platform device addressing

* `<reg>` is represented in form of `reg = <base0 length0 [bash1 length1] ... >`.
* `#size-cells` tell how large the length field in each child `reg` tuple.
* `#address-cells` tell how many cells we must use to specify an address.

## Resources

With the resources being named, whatever their indexes are, a given name will always match the resource.

```c
fake_device { 
    compatible = "packt,fake-device"; 
    reg = <0x02020000 0x4000>, <0x4a064800 0x200>, <0x4a064c00 0x200>; 
    reg-names = "config", "ohci", "ehci"; 
    interrupts = <0 66 IRQ_TYPE_LEVEL_HIGH>, <0 67 IRQ_TYPE_LEVEL_HIGH>; 
    interrupt-names = "ohci", "ehci"; 
    clocks = <&clks IMX6QDL_CLK_UART_IPG>, <&clks IMX6QDL_CLK_UART_SERIAL>; 
    clock-names = "ipg", "per"; 
    dmas = <&sdma 25 4 0>, <&sdma 26 4 0>; 
    dma-names = "rx", "tx"; 
};
```
* `reg-names`: This is for a list of memory regions in the `reg` property
* `clock-names`: This is to name `clocks` in the clocks property
* `interrupt-names`: This give a name to each `interrupt` in the interrupts property
* `dma-names`: This is for the `dma` property

API to access resources:
```c
struct resource *res1, *res2; 
res1 = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ohci"); 
res2 = platform_get_resource_byname(pdev, IORESOURCE_MEM, "config"); 
 
struct dma_chan  *dma_chan_rx, *dma_chan_tx; 
dma_chan_rx = dma_request_slave_channel(&pdev->dev, "rx"); 
dma_chan_tx = dma_request_slave_channel(&pdev->dev, "tx"); 
 
inttxirq, rxirq; 
txirq = platform_get_irq_byname(pdev, "ohci"); 
rxirq = platform_get_irq_byname(pdev, "ehci"); 
 
structclk *clck_per, *clk_ipg; 
clk_ipg = devm_clk_get(&pdev->dev, "ipg"); 
clk_ipg = devm_clk_get(&pdev->dev, "pre"); 
```



### OF match style

You can check if the DT node is set to know whether the driver has been loaded in response to an `of_match`, or instantiated from within the board's `init` file.
```c
static int my_probe(struct platform_device *pdev) 
{ 
    struct device_node *np = pdev->dev.of_node; 
    const struct of_device_id *match; 
 
    match = of_match_device(imx_uart_dt_ids, &pdev->dev); 
    if (match) { 
        /* Devicetree, extract the data */ 
        my_data = match->data; 
    } else { 
        /* Board init file */ 
        my_data = dev_get_platdata(&pdev->dev); 
    } 
    [...] 
} 
```

