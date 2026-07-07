#include <linux/init.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/timer.h>
#include <linux/version.h>
#include <linux/workqueue.h>

struct lifecycle_state {
	struct delayed_work work;
	struct timer_list timer;
};

static struct platform_device *demo_pdev;

static void lifecycle_work_fn(struct work_struct *work)
{
	pr_info("platform_lifecycle_demo: delayed work executed\n");
}

static void lifecycle_timer_fn(struct timer_list *timer)
{
	pr_info("platform_lifecycle_demo: timer callback executed\n");
}

static int lifecycle_probe(struct platform_device *pdev)
{
	struct lifecycle_state *state;

	state = kzalloc(sizeof(*state), GFP_KERNEL);
	if (!state)
		return -ENOMEM;

	INIT_DELAYED_WORK(&state->work, lifecycle_work_fn);
	timer_setup(&state->timer, lifecycle_timer_fn, 0);

	platform_set_drvdata(pdev, state);
	schedule_delayed_work(&state->work, msecs_to_jiffies(1000));
	mod_timer(&state->timer, jiffies + msecs_to_jiffies(1500));

	pr_info("platform_lifecycle_demo: probe complete\n");
	return 0;
}

static void lifecycle_remove_common(struct platform_device *pdev)
{
	struct lifecycle_state *state = platform_get_drvdata(pdev);

	pr_info("platform_lifecycle_demo: remove start\n");
	cancel_delayed_work_sync(&state->work);
	del_timer_sync(&state->timer);
	kfree(state);
	pr_info("platform_lifecycle_demo: remove complete after work/timer cleanup\n");
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(6, 11, 0)
static void lifecycle_remove(struct platform_device *pdev)
{
	lifecycle_remove_common(pdev);
}
#else
static int lifecycle_remove(struct platform_device *pdev)
{
	lifecycle_remove_common(pdev);
	return 0;
}
#endif

static struct platform_driver lifecycle_driver = {
	.probe = lifecycle_probe,
	.remove = lifecycle_remove,
	.driver = {
		.name = "platform_lifecycle_demo",
	},
};

static int __init platform_lifecycle_demo_init(void)
{
	int ret;

	ret = platform_driver_register(&lifecycle_driver);
	if (ret)
		return ret;

	demo_pdev = platform_device_register_simple("platform_lifecycle_demo", -1, NULL, 0);
	if (IS_ERR(demo_pdev)) {
		ret = PTR_ERR(demo_pdev);
		platform_driver_unregister(&lifecycle_driver);
		return ret;
	}

	pr_info("platform_lifecycle_demo: module loaded\n");
	return 0;
}

static void __exit platform_lifecycle_demo_exit(void)
{
	platform_device_unregister(demo_pdev);
	platform_driver_unregister(&lifecycle_driver);
	pr_info("platform_lifecycle_demo: module unloaded\n");
}

module_init(platform_lifecycle_demo_init);
module_exit(platform_lifecycle_demo_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("linux-kernel-hacker-roadmap");
MODULE_DESCRIPTION("Day 28 platform driver lifecycle demo module");
