#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/interrupt.h>
#include <linux/irqdesc.h>

static int irq_num = 219;
module_param(irq_num, int, 0444);
MODULE_PARM_DESC(irq_num, "IRQ number to inspect");

static int __init zhutest_irq_inspect_init(void) {
    struct irq_desc* desc;
    struct irqaction* action;

    desc = irq_to_desc(irq_num);
    if (!desc) {
        pr_err("Zhutest: Cannot find descriptor for IRQ %d\n", irq_num);
        return -EINVAL;
    }

    action = desc->action;
    if (!action) {
        pr_info("Zhutest: No action registered for IRQ %d\n", irq_num);
        return 0;
    }

    while (action) {
        pr_info("Zhutest: IRQ %d handler: %ps (device: %s)\n", irq_num, action->handler, action->name);
        action = action->next;
    }

    return 0;
}

static void __exit zhutest_irq_inspect_exit(void) {
    pr_info("Zhutest: Module unloaded!\n");
}

module_init(zhutest_irq_inspect_init);
module_exit(zhutest_irq_inspect_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Wanli Zhu");
MODULE_DESCRIPTION("Get IRQ hander function name for specified IRQ number");